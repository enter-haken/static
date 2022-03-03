defmodule Static.Folder do
  alias __MODULE__

  alias Static.Site
  alias Static.Parameter
  alias Static.NestedSet

  @derive Jason.Encoder

  @type t :: %Folder{
          sites: [Site.t() | Folder.t()],
          parameter: Parameter.t(),
          lnum: pos_integer(),
          rnum: pos_integer()
        }

  defstruct sites: [],
            parameter: nil,
            lnum: nil,
            rnum: nil

  def create(parameter, sites) do
    %Folder{
      parameter: parameter,
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

    populated_sites =
      found_sites
      |> Enum.map(fn %Site{url: active_url} = site ->
        %Site{
          site
          | breadcrumb: NestedSet.breadcrumb(nested_set, site),
            siblings:
              sites
              |> Enum.map(fn possible_active_site ->
                if is_struct(possible_active_site, Folder) do
                  %Folder{sites: [first_site | _rest]} = possible_active_site
                  first_site
                else
                  %Site{url: possible_active_url} = possible_active_site

                  if possible_active_url == active_url do
                    %Site{possible_active_site | is_active: true}
                  else
                    possible_active_site
                  end
                end
              end)
              |> Enum.filter(fn %Site{title: title} -> not is_nil(title) end)
        }
      end)

    found_folders =
      sites
      |> Enum.filter(fn x -> Kernel.is_struct(x, Folder) end)
      |> Enum.map(fn found_folder -> populate_breadcrumb(found_folder, nested_set) end)

    %Folder{folder | sites: populated_sites ++ found_folders}
  end
end
