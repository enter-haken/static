defmodule GenerateTest do
  use ExUnit.Case

  alias Static.Generate

  setup do
    on_exit(fn ->
      File.rm_rf!("tmp")
    end)

    :ok
  end

  describe "It is expected to get an output for" do
    test "one file in the content folder" do
      Generate.main([
        "--content-path",
        "test/fixture/simple",
        "--output-path",
        "tmp/output",
        "--template",
        "test/fixture/only_body_template.eex"
      ])

      assert {"""
              tmp/output
              └── index.html

              0 directories, 1 file
              """, 0} == System.cmd("tree", ["tmp/output"])
    end

    test "four files in the content folder" do
      Generate.main([
        "--content-path",
        "test/fixture/one_folder",
        "--output-path",
        "tmp/output",
        "--template",
        "test/fixture/only_body_template.eex"
      ])

      assert {"""
              tmp/output
              ├── index.html
              ├── one.html
              ├── three.html
              └── two.html

              0 directories, 4 files
              """, 0} == System.cmd("tree", ["tmp/output"])
    end

    test "four files with breadcrumbs in the content folder" do
      Generate.main([
        "--content-path",
        "test/fixture/one_folder",
        "--output-path",
        "tmp/output",
        "--template",
        "test/fixture/breadcrumb_template.eex"
      ])

      assert {"""
              tmp/output
              ├── index.html
              ├── one.html
              ├── three.html
              └── two.html

              0 directories, 4 files
              """, 0} == System.cmd("tree", ["tmp/output"])
    end

    test "one subdirectory with seven files." do
      Generate.main([
        "--content-path",
        "test/fixture/two_folders",
        "--output-path",
        "tmp/output",
        "--template",
        "test/fixture/breadcrumb_template.eex"
      ])

      assert {"""
              tmp/output
              ├── index.html
              ├── one.html
              ├── three.html
              └── two
                  ├── index.html
                  ├── one.html
                  ├── three.html
                  └── two.html

              1 directory, 7 files
              """, 0} == System.cmd("tree", ["tmp/output"])
    end

    test "subfolder" do
      Generate.main([
        "--content-path",
        "test/fixture/two_folders",
        "--output-path",
        "tmp/output",
        "--template",
        "test/fixture/breadcrumb_template.eex",
        "--static-path",
        "test/fixture/static_files"
      ])

      assert {"""
              tmp/output
              ├── files.txt
              ├── index.html
              ├── one.html
              ├── some.txt
              ├── static.txt
              ├── three.html
              └── two
                  ├── index.html
                  ├── one.html
                  ├── three.html
                  └── two.html

              1 directory, 10 files
              """, 0} == System.cmd("tree", ["tmp/output"])
    end
  end
end
