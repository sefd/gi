use_inline_resources

action :install do
  name = name
  repository = new_resource.repo
  revision = new_resource.revision
  output_dir = new_resource.output_dir

  cache = Chef::Config[:file_cache_path]

  git "download #{name}" do
    repository repository
    reference revision
    destination File.join(cache, name)
    action :sync
    notifies :run, "bash[compile #{name}]"
  end

  bash "compile #{name}" do
    user "root"
    cwd File.join(cache, name)
    code new_resource.cmd

    new_resource.binaries.each do |binary|
      notifies :run, "bash[copy #{binary}]", :immediately
    end

    not_if new_resource.binaries.map {|b| "type #{b}"}.join(" && ")

    action :nothing
  end

  copies = new_resource.binaries.each do |binary|
    bash "copy #{binary}" do
      user "root"
      cwd File.join(cache, name)
      code "cp ./#{output_dir}/#{binary} /usr/local/#{binary}}"

      subscribes :run, "bash[compile #{name}]", :immediately

      not_if "type #{binary}"

      action :nothing
    end
  end

  status = copies.map {|s| s.updated_by_last_action?}.reduce {|acc, c| acc || c}

  new_resource.updated_by_last_action status
end
