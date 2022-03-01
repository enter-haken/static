defmodule Mix.Tasks.Static.Generate do
  @moduledoc """

  """
  @shortdoc """
    generates a static site
  """

  @tree_result_as_json_with_full_path "-Jf"
  @no_report_at_the_end_of_tree_result "--noreport"

  use Mix.Task
  alias __MODULE__

  alias Static.Site
  alias Static.Folder

  @switches [
    content_path: :string,
    output_path: :string
  ]

  defstruct content_path: nil,
            output_path: nil

  @impl Mix.Task
  def run(args) do
    %Generate{
      content_path: content_path
    } =
      args
      |> create!()

    with {raw_tree, 0} <-
           System.cmd("tree", [
             @tree_result_as_json_with_full_path,
             @no_report_at_the_end_of_tree_result,
             content_path
           ]),
         {:ok, raw_content_tree} <- Jason.decode(raw_tree) do
      sites =
        raw_content_tree
        |> get_sites(content_path)

      nested_set = sites |> Static.NestedSet.flattened_set()

      sites
      |> set_breadcrumb(nested_set)
      |> IO.inspect()

      # |> Static.NestedSet.breadcrumb("/tmp/content/02-draft-environment/04-packages/18-feh.md")
      # |> IO.inspect()
    end
  end

  # TODO: sane error messages for the user
  defp create!(args) do
    case args
         |> OptionParser.parse!(strict: @switches) do
      {parsed_options, [] = _no_rest} ->
        %Generate{
          content_path:
            if Keyword.has_key?(parsed_options, :content_path) do
              Keyword.get(parsed_options, :content_path)
            else
              raise "content path not found"
            end,
          output_path:
            if Keyword.has_key?(parsed_options, :output_path) do
              Keyword.get(parsed_options, :output_path)
            else
              raise "output path not found"
            end
        }

      unknown ->
        raise "could not parse options. #{inspect(unknown)}"
    end
  end

  defp get_sites(
         %{"name" => file_name, "type" => "file"} = _raw_content_tree,
         content_path
       ) do
    Site.create(file_name, content_path)
  end

  defp get_sites(
         %{"type" => "directory", "contents" => sites, "name" => name} = _raw_content_tree,
         content_path
       ) do
    Folder.create(
      name,
      content_path,
      sites
      |> Enum.map(fn site -> get_sites(site, content_path) end)
    )
  end

  defp get_sites(
         [%{"type" => "directory", "contents" => sites, "name" => name}] = _raw_content_tree,
         content_path
       ) do
    Folder.create(
      name,
      content_path,
      sites
      |> Enum.map(fn site -> get_sites(site, content_path) end)
    )
  end

  defp set_breadcrumb(%Folder{sites: sites} = folder, nested_set) do
    found_sites =
      sites
      |> Enum.filter(fn x -> Kernel.is_struct(x, Site) end)
      |> Enum.map(fn site ->
        %Site{site | breadcrumb: Static.NestedSet.breadcrumb(nested_set, site)}
      end)

    found_folders =
      sites
      |> Enum.filter(fn x -> Kernel.is_struct(x, Folder) end)
      |> Enum.map(fn found_folder -> set_breadcrumb(found_folder, nested_set) end)

    %Folder{folder | sites: found_sites ++ found_folders}
  end
end
