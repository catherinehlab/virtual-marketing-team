import { supabaseServer } from "@/lib/supabase";

type KPI = {
  total_conversions: number;
  total_profile_clicks: number;
  total_phone_clicks: number;
  total_spend_krw: number;
};

async function getKPIs(clientId: string): Promise<KPI> {
  const sb = supabaseServer();
  const { data, error } = await sb
    .from("kpi_last_30d")
    .select("*")
    .eq("client_id", clientId)
    .maybeSingle();
  if (error) console.error(error);
  return (data as KPI) ?? {
    total_conversions: 0,
    total_profile_clicks: 0,
    total_phone_clicks: 0,
    total_spend_krw: 0,
  };
}

function Card({ title, value, sub }:{title:string; value:string; sub?:string}) {
  return (
    <div className="rounded-2xl p-5 shadow-sm border bg-white">
      <div className="text-sm text-gray-500">{title}</div>
      <div className="text-2xl font-semibold mt-1">{value}</div>
      {sub && <div className="text-xs text-gray-400 mt-1">{sub}</div>}
    </div>
  );
}

export default async function Home() {
  const clientId = "catherineh-lab";
  const kpi = await getKPIs(clientId);
  const format = (n: number) => new Intl.NumberFormat("ko-KR").format(Number(n||0));

  return (
    <main className="p-6 md:p-10 space-y-6">
      <h1 className="text-2xl font-bold">Catherineh Lab — Virtual Marketing Team Dashboard</h1>

      <section className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
        <Card title="예약/전환(30d)" value={format(kpi.total_conversions)} sub="웹/DM/전화/폼" />
        <Card title="프로필 클릭(30d)" value={format(kpi.total_profile_clicks)} sub="IG/GBP/Naver" />
        <Card title="전화 클릭(30d)" value={format(kpi.total_phone_clicks)} sub="GBP/Naver" />
        <Card title="광고 지출(월)" value={format(kpi.total_spend_krw)} sub="KRW" />
      </section>
    </main>
  );
}

