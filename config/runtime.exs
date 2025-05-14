import Config

if System.get_env("PHX_SERVER") do
  config :umm, UmmWeb.Endpoint, server: true
end

  if config_env() == :prod do

  IO.inspect(System.get_env(), label: "ENV Vars at runtime")
  IO.inspect(Application.get_env(:umm, UmmWeb.Endpoint), label: "Endpoint config")

  secret_key_base =
    System.get_env("SECRET_KEY_BASE") ||
      raise """
      environment variable SECRET_KEY_BASE is missing.
      You can generate one by calling: mix phx.gen.secret
      """

  host = System.get_env("PHX_HOST") || "example.com"
  port = String.to_integer(System.get_env("PORT") || "4000")

    config :umm, :dns_cluster_query, System.get_env("DNS_CLUSTER_QUERY")

  config :agg, AggWeb.Endpoint,
         url: [host: host, port: 80],
         http: [ip: {0, 0, 0, 0}, port: port],
         secret_key_base: secret_key_base



  topologies = [
    umm_cluster: [
      strategy: Cluster.Strategy.DNSPoll,
      config: [
        polling_interval: 5_000,
        query: "umm.local",
        node_basename: "umm"
      ]
    ]
  ]

  config :libcluster,
         topologies: topologies

end
