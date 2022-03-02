defmodule Static.Site do
  require Logger

  alias __MODULE__

  @derive Jason.Encoder

  @type t :: %Site{
          base_path: String.t(),
          breadcrumb: [
            %{
              href: String.t(),
              title: String.t()
            }
          ],
          siblings: [
            %{
              href: String.t(),
              title: String.t()
            }
          ],
          content_filename: String.t(),
          relative_content_filename: String.t(),
          url: String.t(),
          raw_markdown: String.t(),
          ast: term(),
          html: String.t(),
          lnum: pos_integer(),
          rnum: pos_integer()
        }

  defstruct base_path: nil,
            # TODO: works only with fully populated site
            breadcrumb: [],

            # TODO: works only with fully populated site
            # TODO: sibling functions in folder module?
            siblings: [],
            raw_markdown: nil,
            ast: nil,
            html: nil,
            relative_content_filename: nil,
            content_filename: nil,
            url: nil,
            lnum: nil,
            rnum: nil

  def create(file_name, base_path) do
    %Site{
      base_path: base_path,
      content_filename: file_name,
      relative_content_filename: file_name |> Path.relative_to(base_path)
    }

    # TODO: depends on parsed markdown content (for title)
    |> set_url()
    |> read()
    |> case do
      {:ok, site} ->
        site

      _ ->
        %Site{}
    end
    |> ast()
    |> parse()
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

  defp set_url(%Site{relative_content_filename: relative_content_filename} = site) do
    %Site{
      site
      | url:
          relative_content_filename
          |> String.replace(~r/\/\d{1,2}-/, "/")
          |> String.replace(~r/^\d{1,2}-/, "")
          |> String.replace(~r/\.md$/, ".html")
    }
  end

  defp read(%Site{content_filename: content_filename} = site) do
    case File.read(content_filename) do
      {:ok, content} ->
        {:ok, %Site{site | raw_markdown: content}}

      err ->
        Logger.error("could not read file #{content_filename}. #{inspect(err)}")
        {:error, :eread}
    end
  end

  defp ast(%Site{raw_markdown: nil} = site), do: site

  defp ast(%Site{raw_markdown: raw_markdown} = site) do
    %Site{
      site
      | ast:
          raw_markdown
          |> EarmarkParser.as_ast()
          |> case do
            {:ok, ast, _} ->
              ast

            _ ->
              Logger.warn("could not parse markdown")

              nil
          end
    }
  end

  defp parse(%Site{ast: nil} = site), do: site

  defp parse(%Site{ast: ast} = site) do
    %Site{
      site
      | html: Earmark.Transform.transform(ast)
    }
  end
end
