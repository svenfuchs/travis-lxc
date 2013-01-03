execute 'apt-get-update-periodic' do
  stamp = '/var/lib/apt/periodic/update-success-stamp'
  command "apt-get update && touch #{stamp}"
  ignore_failure true
  only_if { !File.exists?(stamp) or File.mtime(stamp) < Time.now - 86400 }
end
