defmodule Static.Generate do
  @moduledoc """

  """

  @tree_result_as_json_with_full_path "-Jf"
  @no_report_at_the_end_of_tree_result "--noreport"

  alias Static.Site
  alias Static.Folder
  alias Static.NestedSet

  def main(args) do
    %Static.Parameter{
      content_path: content_path,
      output_path: output_path,
      static_path: static_path
    } = params = Static.Parameter.get_params(args)

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
      |> read_root(params)
      |> NestedSet.populate_lnum_rnum()
      |> Folder.populate_breadcrumb()
      |> NestedSet.flatten()
      |> Enum.map(&Site.envelop/1)
      |> Enum.map(&Site.write/1)

      if not is_nil(static_path) do
        File.cp_r!(static_path, output_path)
      end
    end
  end

  defp get_sites(
         %{"name" => file_name, "type" => "file"} = _raw_content_tree,
         parameter
       ) do
    Site.create(file_name, parameter)
  end

  defp get_sites(
         %{"type" => "directory", "contents" => sites} = _raw_content_tree,
         parameter
       ) do
    Folder.create(
      parameter,
      sites
      |> Enum.map(fn site -> get_sites(site, parameter) end)
    )
  end

  defp read_root(
         [%{"type" => "directory", "contents" => raw_sites}] = _raw_content_tree,
         parameter
       ) do
    Folder.create(
      parameter,
      raw_sites
      |> Enum.map(fn site -> get_sites(site, parameter) end)
    )
  end
end
