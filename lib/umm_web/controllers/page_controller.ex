defmodule UmmWeb.PageController do
  use UmmWeb, :controller

#  def home(conn, _params) do
#    # The home page is often custom made,
#    # so skip the default app layout.
#    render(conn, :home, layout: false)
#  end

  def home(conn, _params) do
    text(conn, "UMM is alive 🚀")
  end
end
