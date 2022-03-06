defmodule Static.Meta do
  alias __MODULE__

  @type t :: %Meta{
          created_at: Date.t()
        }

  defstruct created_at: nil

  def create(nil), do: %Meta{}

  def create(raw) do
    with {:ok, %{"created_at" => raw_created_at}} <- YamlElixir.read_from_string(raw),
         {:ok, created_at} <- Date.from_iso8601(raw_created_at) do
      %Meta{created_at: created_at}
    else
      _ -> %Meta{}
    end
  end
end
