defmodule Static.NestedSet do
  alias Static.Folder
  alias Static.Site

  def get_set(folder, lnum \\ 1)

  def get_set(%Site{} = site, lnum) do
    %Site{site | lnum: lnum, rnum: lnum + 1}
  end

  def get_set(%Folder{sites: sites} = folder, lnum) do
    %{last: %{rnum: last_rnum}, values: updated_sites} =
      sites
      |> Enum.reduce(%{last: nil, values: []}, fn e, %{last: last} = acc ->
        next =
          case last do
            nil ->
              get_set(e, lnum + 1)

            %{rnum: last_rnum} ->
              get_set(e, last_rnum + 1)
          end

        %{last: next, values: acc.values ++ [next]}
      end)

    %Folder{folder | lnum: lnum, rnum: last_rnum + 1, sites: updated_sites}
  end

  def flatten(%Folder{lnum: lnum, rnum: rnum, sites: sites}) do
    found_sites =
      sites
      |> Enum.filter(fn x -> Kernel.is_struct(x, Site) end)
      # Add the first site of the folder to list, so breadcrumb will work
      |> Kernel.++([%Site{(sites |> List.first()) | lnum: lnum, rnum: rnum}])

    sites
    |> Enum.filter(fn x -> Kernel.is_struct(x, Folder) end)
    |> Enum.map(&flatten/1)
    |> List.flatten()
    |> Kernel.++(found_sites)
    |> List.flatten()
    |> Enum.sort_by(fn %Site{lnum: lnum} -> lnum end)
  end

  def flattened_set(folder, lnum \\ 1) do
    get_set(folder, lnum)
    |> flatten()
  end

  def breadcrumb(sites, %Site{content_filename: content_filename}) do
    case sites
         |> Enum.find(fn %Site{content_filename: possible_content_filename} ->
           possible_content_filename == content_filename
         end) do
      nil ->
        []

      %Site{lnum: lnum, rnum: rnum} ->
        sites
        |> Enum.filter(fn %Site{lnum: lnum_to_compare, rnum: rnum_to_compare} ->
          lnum_to_compare <= lnum and rnum_to_compare >= rnum
        end)
    end
  end
end
