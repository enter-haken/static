defmodule Mix.Tasks.Static.Generate do
  @moduledoc """

  """
  @shortdoc """
    generates a static site
  """

  @tree_result_as_json_with_full_path "-Jf"
  @no_report_at_the_end_of_tree_result "--noreport"

  use Mix.Task

  alias Static.Site
  alias Static.Folder
  alias Static.NestedSet

  @impl Mix.Task
  def run(args) do
    %Static.Parameter{
      content_path: content_path,
      output_path: output_path
    } = Static.Parameter.get_params(args)

    if not File.dir?(output_path) do
      File.mkdir_p(output_path)
    end

    with {raw_tree, 0} <-
           System.cmd("tree", [
             @tree_result_as_json_with_full_path,
             @no_report_at_the_end_of_tree_result,
             content_path
           ]),
         {:ok, raw_content_tree} <- Jason.decode(raw_tree) do
      raw_content_tree
      |> read_root(content_path, output_path)
      |> NestedSet.populate_lnum_rnum()
      |> Folder.populate_breadcrumb()
      # TODO: poupulate siblings
      # ----------------------------------
      # when site is conpletely populated:
      # ----------------------------------
      # TODO: parse markdown
      # TODO: create default template -> Tailwind?
      # TODO: how to use custom templates?
      # TODO: copy static content
    end
  end

  defp get_sites(
         %{"name" => file_name, "type" => "file"} = _raw_content_tree,
         content_path,
         output_path
       ) do
    Site.create(file_name, content_path, output_path)
  end

  defp get_sites(
         %{"type" => "directory", "contents" => sites, "name" => name} = _raw_content_tree,
         content_path,
         output_path
       ) do
    Folder.create(
      name,
      content_path,
      sites
      |> Enum.map(fn site -> get_sites(site, content_path, output_path) end)
    )
  end

  defp read_root(
         [%{"type" => "directory", "contents" => raw_sites, "name" => name}] = _raw_content_tree,
         content_path,
         output_path
       ) do
    Folder.create(
      name,
      content_path,
      raw_sites
      |> Enum.map(fn site -> get_sites(site, content_path, output_path) end)
    )
  end
end
