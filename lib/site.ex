defmodule Static.Site do
  require Logger

  alias __MODULE__

  @derive Jason.Encoder

  @type t :: %Site{
          sites: [Site.t()],
          base_path: String.t(),
          content_filename: String.t(),
          relative_content_filename: String.t(),
          raw_content: String.t(),
          is_root: boolean
        }

  defstruct sites: [],
            base_path: nil,
            raw_content: nil,
            relative_content_filename: nil,
            content_filename: nil,
            is_root: false

  def create_root(sites), do: %Site{is_root: true, sites: sites}

  def create(file_name, base_path) do
    %Site{
      base_path: base_path,
      content_filename: file_name,
      relative_content_filename: file_name |> Path.relative_to(base_path)
    }
  end

  def process(site) do
    site
    |> read
    |> case do
      {:ok, content} ->
        content

      {:error, :eread} ->
        {:error, :eread}
    end
  end

  defp read(%Site{content_filename: content_filename} = site) do
    case File.read(content_filename) do
      {:ok, content} ->
        {:ok, %Site{site | raw_content: content}}

      err ->
        Logger.error("could not read file #{content_filename}. #{inspect(err)}")
        {:error, :eread}
    end
  end
end
