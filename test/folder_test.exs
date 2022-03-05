defmodule FolderTest do
  use ExUnit.Case

  alias Static.Folder

  describe "It is expected to get" do
    test "an initial folder struct with" do
      assert %Folder{parameter: "parameter", sites: []} == Folder.create("parameter", [])
    end
  end
end
