# lib/umm_web/controllers/dlr_controller.ex
defmodule UmmWeb.DLRController do
  use UmmWeb, :controller

  def create(conn, params) do
    IO.inspect(params, label: "📥 DLR RECEIVED")
    send_resp(conn, 200, "ok")
  end
end
