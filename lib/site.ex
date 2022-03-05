defmodule Static.Site do
  require Logger

  alias __MODULE__
  alias Static.Parameter

  @derive Jason.Encoder

  @derive {Inspect, only: [:ast, :body, :breadcrumb, :lnum, :rnum, :title, :url]}

  @teaser_marker {:comment, [], ["more"], %{comment: true}}

  @type t :: %Site{
          parameter: Parameter.t(),
          breadcrumb: [Site.t()],
          siblings: [Site.t()],
          content_filename: String.t(),
          relative_content_filename: String.t(),
          title: String.t(),
          url: String.t(),
          raw_markdown: String.t(),
          ast: term(),
          body: String.t(),
          html: String.t(),
          teaser: String.t(),
          target_file: String.t(),
          lnum: pos_integer(),
          rnum: pos_integer(),
          is_active: boolean(),
          should_generate_teasers: boolean()
        }

  defstruct parameter: nil,
            breadcrumb: [],
            siblings: [],
            raw_markdown: nil,
            ast: nil,
            body: nil,
            html: nil,
            teaser: nil,
            target_file: nil,
            relative_content_filename: nil,
            content_filename: nil,
            title: nil,
            url: nil,
            lnum: nil,
            rnum: nil,
            is_active: false,
            should_generate_teasers: false

  def create(file_name, %Parameter{content_path: content_path} = parameter) do
    %Site{
      parameter: parameter,
      content_filename: file_name,
      relative_content_filename: file_name |> Path.relative_to(content_path)
    }
    |> set_url()
    |> set_target_file()
    |> read()
    |> ast()
    |> rewrite_ast()
    |> teaser()
    |> title()
    |> parse()
  end

  def envelop(
        %Site{
          parameter: %Parameter{template: template},
          body: body,
          relative_content_filename: relative_content_filename,
          breadcrumb: breadcrumb,
          siblings: siblings,
          should_generate_teasers: should_generate_teasers
        } = site
      ) do
    %Site{
      site
      | html:
          EEx.eval_file(template,
            assigns: [
              body: body,
              title: relative_content_filename,
              breadcrumb: breadcrumb,
              siblings: siblings,
              should_generate_teasers: should_generate_teasers
            ]
          )
    }
  end

  def write(%Site{target_file: target_file, html: html} = site) do
    with :ok <- target_file |> Path.dirname() |> File.mkdir_p(),
         :ok <- target_file |> File.write(html) do
      site
    else
      err ->
        Logger.error("could not write #{target_file}. #{inspect(err)}")
    end
  end

  defp title(%Site{ast: [{"h1", [], [title], %{}} | _rest]} = site),
    do: %Site{site | title: title}

  defp title(site), do: site

  defp set_url(%Site{relative_content_filename: relative_content_filename} = site) do
    %Site{
      site
      | url:
          "/#{relative_content_filename |> String.replace(~r/\/\d{1,2}-/, "/") |> String.replace(~r/^\d{1,2}-/, "") |> String.replace(~r/\.md$/, ".html")}"
    }
  end

  defp set_target_file(
         %Site{
           url: url,
           parameter: %Parameter{output_path: output_path}
         } = site
       ) do
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

  defp teaser(%Site{ast: ast} = site) do
    if ast |> Enum.any?(&has_teaser?/1) do
      %Site{
        site
        | teaser:
            ast
            |> Enum.take_while(&teaser_has_not_been_reached?/1)
            |> Earmark.Transform.transform()
      }
    else
      site
    end
  end

  defp has_teaser?(ast), do: ast == @teaser_marker

  defp teaser_has_not_been_reached?(ast), do: ast != @teaser_marker

  defp rewrite_ast(%Site{ast: ast} = site) do
    %Site{site | ast: ast |> Enum.map(&walk/1) |> Enum.filter(fn x -> not is_nil(x) end)}
  end

  defp walk(
         {"pre", [],
          [
            {"code", [{"class", "{lang=dot}"}], [graphviz_content], %{}}
          ], %{}}
       ) do
    {image, 0} = "echo '#{graphviz_content}' | dot -Tpng" |> bash()

    {"p", [{"style", "text-align:center"}],
     [
       {"img", [{"src", "data:image/png;base64,#{Base.encode64(image)}"}, {"alt", "asd"}], [],
        %{}}
     ], %{}}
  end

  defp walk(@teaser_marker), do: @teaser_marker

  defp walk({:comment, [], _comments, %{comment: true}}), do: nil

  defp walk(other) do
    other
  end

  def bash(script), do: System.cmd("sh", ["-c", script])
end
