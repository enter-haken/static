defmodule Static.Folder do
  alias __MODULE__

  alias Static.Site
  alias Static.NestedSet

  @derive Jason.Encoder

  @type t :: %Folder{
          sites: [Site.t() | Folder.t()],
          base_path: String.t(),
          content_folder: String.t(),
          relative_content_folder: String.t(),
          lnum: pos_integer(),
          rnum: pos_integer()
        }

  defstruct sites: [],
            base_path: nil,
            content_folder: nil,
            relative_content_folder: nil,
            lnum: nil,
            rnum: nil

  def create(content_folder, base_path, sites) do
    %Folder{
      content_folder: content_folder,
      base_path: base_path,
      sites: sites
    }
  end

  def populate_breadcrumb(root_folder) do
    populate_breadcrumb(root_folder, root_folder |> NestedSet.flattened_tree())
  end

  defp populate_breadcrumb(%Folder{sites: sites} = folder, nested_set) do
    found_sites =
      sites
      |> Enum.filter(fn x -> Kernel.is_struct(x, Site) end)
      |> Enum.map(fn site ->
        %Site{
          site
          | breadcrumb:
              NestedSet.breadcrumb(nested_set, site)
              |> Enum.map(fn %Site{url: url} -> %{url: url, title: nil} end)
        }
      end)

    found_folders =
      sites
      |> Enum.filter(fn x -> Kernel.is_struct(x, Folder) end)
      |> Enum.map(fn found_folder -> populate_breadcrumb(found_folder, nested_set) end)

    %Folder{folder | sites: found_sites ++ found_folders}
  end
end
