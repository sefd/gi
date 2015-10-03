actions :install
default_action :install

attribute :name, kind_of: String, name_attribute: true, required: true

attribute :repo, kind_of: String, required: true
attribute :revision, kind_of: String, required: true

attribute :build_cmd, kind_of: String, default: "./build"
attribute :output_dir, kind_of: String, default: "./bin"
attribute :binaries, kind_of: Array, required: true
