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
          body: String.t(),
          html: String.t(),
          output_path: String.t(),
          target_file: String.t(),
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
            body: nil,
            html: nil,
            output_path: nil,
            target_file: nil,
            relative_content_filename: nil,
            content_filename: nil,
            url: nil,
            lnum: nil,
            rnum: nil

  def create(file_name, base_path, output_path) do
    %Site{
      base_path: base_path,
      output_path: output_path,
      content_filename: file_name,
      relative_content_filename: file_name |> Path.relative_to(base_path)
    }

    # TODO: depends on parsed markdown content (for title)
    |> set_url()
    |> set_target_file()
    |> read()
    |> ast()
    |> parse()
    |> envelop()
    |> write()
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

  defp set_target_file(%Site{url: url, output_path: output_path} = site) do
    %Site{
      site
      | target_file: Path.join([output_path, url])
    }
  end

  defp read(%Site{content_filename: content_filename} = site) do
    case File.read(content_filename) do
      {:ok, content} ->
        %Site{site | raw_markdown: content}

      err ->
        Logger.warn("could not read file #{content_filename}. #{inspect(err)}")
        site
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
            {:ok, ast, _deprecation_messages} ->
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
      | body: Earmark.Transform.transform(ast)
    }
  end

  defp envelop(%Site{body: body, relative_content_filename: relative_content_filename} = site) do
    %Site{
      site
      | html:
          EEx.eval_file("lib/template/default.eex", body: body, title: relative_content_filename)
    }
  end

  defp write(%Site{target_file: target_file, html: html} = site) do
    with :ok <- target_file |> Path.dirname() |> File.mkdir_p(),
         :ok <- target_file |> File.write(html) do
      site
    else
      err ->
        Logger.error("could not write #{target_file}. #{inspect(err)}")
    end
  end
end
