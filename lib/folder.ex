defmodule Static.Folder do
  alias __MODULE__

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

  # TODO: redirect to first site

  def create(content_folder, base_path, sites) do
    %Folder{
      content_folder: content_folder,
      base_path: base_path,
      sites: sites
    }
  end
end
