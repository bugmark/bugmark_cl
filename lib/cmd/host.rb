class Host < ThorBase
  desc "info", "show current host info"
  def info
    host = BmxApiRuby::HostApi.new(client)
    runput { host.get_host_info }
  end

  desc "ping", "ping the host"
  def ping
    host = BmxApiRuby::HostApi.new(client)
    runput { host.get_host_ping }
  end

  desc "counts", "show host object count"
  def counts
    host = BmxApiRuby::HostApi.new(client)
    runput {host.get_host_counts}
  end

  desc "next_week_ends", "show future week-ending dates"
  option :count    , desc: "week count" , type: :numeric
  option :strftime , desc: "date format", type: :string
  def next_week_ends
    strftime = options[:strftime] || "%Y-%m-%d %H:%M:%S %z"
    date = BmxApiRuby::HostApi.new(client)
    opts = options[:count] ? {count: options[:count]} : {}
    result = run {date.get_host_next_week_ends(opts)}.to_hash
    output(result[:next_week_ends]&.map {|dt| dt.strftime(strftime)} || result)
  end

  desc "increment_day_offset", "increment current day offset"
  option :count , desc: "count increment", type: :numeric
  def increment_day_offset
    date = BmxApiRuby::HostApi.new(client)
    opts = options[:count] ? {count: options[:count]} : {}
    runput { date.put_host_increment_day_offset(opts) }
  end

  desc "rebuild", "destroy all data and rebuild from scratch"
  long_desc <<~EOF
    Destroy all data and rebuild the system.  The rebuilt system will
    have one user: `user/pass` = `admin@bugmark.net/bugmark`

    To run this command, you must post the affirmation parameter:
    `--affirm=destroy_all_data`.

    The `rebuild` command is intended for use on hosts dedicated for
    research and testing.  The rebuild command will work for hosts
    with `mutable` datastores, and will fail for hosts with `permanent`
    datastores.

    Use the `host info` command to view the datastore type.
  EOF
  option :affirm , desc: "destroy_all_data (required!)", type: :string
  def rebuild
    date = BmxApiRuby::HostApi.new(client)
    abort "ERROR: must use '--affirm=destroy_all_data'" unless options[:affirm] == "destroy_all_data"
    runput { date.post_host_rebuild('destroy_all_data') }
  end
end
