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

    test "one subdirectory with 10 files." do
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

  describe "The content of the generated file should contain" do
    test "one file in the content folder" do
      Generate.main([
        "--content-path",
        "test/fixture/simple",
        "--output-path",
        "tmp/output",
        "--template",
        "test/fixture/only_body_template.eex"
      ])

      assert File.read!("tmp/output/index.html") |> String.trim() ==
               """
               <h1>
               only one file</h1>
               <p>
               With content</p>
               """
               |> String.trim()
    end

   test "one file in the content folder without comments" do
      Generate.main([
        "--content-path",
        "test/fixture/comments",
        "--output-path",
        "tmp/output",
        "--template",
        "test/fixture/only_body_template.eex"
      ])

      assert File.read!("tmp/output/index.html") |> String.trim() ==
        "<h1>\ntitle</h1>\n<p>\nSome content</p>\n<!--more-->\n<p>\nSome other content</p>"
    end


    test "an image" do
      Generate.main([
        "--content-path",
        "test/fixture/graphviz",
        "--output-path",
        "tmp/output",
        "--template",
        "test/fixture/only_body_template.eex"
      ])

      assert File.read!("tmp/output/index.html") |> String.trim() ==
               """
               <h1>\ntitle</h1>\n<p style=\"text-align:center\">\n  <img src=\"data:image/png;base64,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\" alt=\"asd\" />\n</p>
               """
               |> String.trim()
    end
  end
end
