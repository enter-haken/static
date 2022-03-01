defmodule Static.Helper do
  alias Static.Folder
  alias Static.Site

  def nested_set(%Site{} = site, lnum) do
    %Site{site | lnum: lnum, rnum: lnum + 1}
  end

  def nested_set(%Folder{sites: sites} = folder, lnum) do
    %{last: %{rnum: last_rnum}, values: updated_sites} =
      sites
      |> Enum.reduce(%{last: nil, values: []}, fn e, %{last: last} = acc ->
        next =
          case last do
            nil ->
              nested_set(e, lnum + 1)

            %{rnum: last_rnum} ->
              nested_set(e, last_rnum + 1)
          end

        %{last: next, values: acc.values ++ [next]}
      end)

    %Folder{folder | lnum: lnum, rnum: last_rnum + 1, sites: updated_sites}
  end
end
