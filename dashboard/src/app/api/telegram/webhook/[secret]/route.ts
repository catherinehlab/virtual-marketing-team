import { NextRequest, NextResponse } from "next/server";
import { supabaseServer } from "@/lib/supabase";

export const runtime = "nodejs";
export const dynamic = "force-dynamic";

export async function POST(req: NextRequest, { params }: { params: { secret: string } }) {
  const expected = process.env.TELEGRAM_WEBHOOK_SECRET!;
  const headerSecret = req.headers.get("x-telegram-bot-api-secret-token") || "";
  const isPreview = process.env.VERCEL_ENV === "preview";
  if (isPreview) return NextResponse.json({ ok: true, preview: true });

  if (!expected || params.secret !== expected || headerSecret !== expected) {
    return NextResponse.json({ ok: false, reason: "forbidden" }, { status: 403 });
  }

  const update = await req.json();

  if (update?.callback_query) {
    const chatId = update.callback_query.message.chat.id;
    const data: string = update.callback_query.data || "";
    const [action, approvalIdRaw, value] = data.split(":");
    const approvalId = Number(approvalIdRaw);
    const status =
      action === "approve" ? "approved" :
      action === "reject"  ? "rejected" : "modified";

    const sb = supabaseServer();
    await sb.from("approvals").update({
      status,
      resolved_at: new Date().toISOString(),
      resolved_by: `telegram:${chatId}`,
      payload: action === "modify" ? { value } as any : undefined
    }).eq("id", approvalId);

    await sb.from("events").insert({
      client_id: "catherineh-lab",
      source: "telegram",
      level: "info",
      message: `approval ${approvalId} -> ${status}`,
      meta: { value }
    });

    const text =
      action === "approve" ? `✅ 승인되었습니다. (#${approvalId})` :
      action === "reject"  ? `❌ 보류되었습니다. (#${approvalId})` :
      `✏️ 변경 값 적용 요청: ${value ?? "입력없음"} (#${approvalId})`;

    await fetch(`https://api.telegram.org/bot${process.env.TELEGRAM_BOT_TOKEN}/sendMessage`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ chat_id: chatId, text }),
    });

    return NextResponse.json({ ok: true });
  }

  if (update?.message?.text?.startsWith("/start")) {
    const chatId = update.message.chat.id;
    await fetch(`https://api.telegram.org/bot${process.env.TELEGRAM_BOT_TOKEN}/sendMessage`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        chat_id: chatId,
        text: "안녕하세요! 승인 알림을 이 채팅으로 보내드릴게요.",
      }),
    });
  }

  return NextResponse.json({ ok: true });
}

