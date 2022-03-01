defmodule Mix.Tasks.Static.Generate do
  @moduledoc """

  """
  @shortdoc """
    generates a static site
  """

  use Mix.Task
  alias __MODULE__

  alias Static.Site

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
           System.cmd("tree", ["-Jf", "--noreport", content_path]),
         {:ok, raw_content_tree} <- Jason.decode(raw_tree) do
      raw_content_tree
      |> get_sites(content_path)
      |> IO.inspect()
    end
  end

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
         %{"type" => "directory", "contents" => sites} = _raw_content_tree,
         content_path
       ) do
    sites
    |> Enum.map(fn site -> get_sites(site, content_path) end)
  end

  defp get_sites(
         [%{"type" => "directory", "contents" => sites}] = _raw_content_tree,
         content_path
       ) do
    sites
    |> Enum.map(fn site -> get_sites(site, content_path) end)
    |> Site.create_root()
  end
end
