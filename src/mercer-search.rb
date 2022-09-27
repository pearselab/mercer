require 'net/http'
require "addressable/uri"
require 'json'

# To do: * Setup API links in config file

desc "Search for something on WoS"
task :wos, [:term, :max_records, :where] do |task, args|
  def url_wrapper(term, start, wok_key)
    uri = URI(Addressable::URI.parse("https://wos-api.clarivate.com/api/wos/?databaseId=WOK&usrQuery=TS%3D%28#{term}%29&count=5&firstRecord=#{start}").normalize.to_s)
    request = Net::HTTP::Get.new(uri)
    request["Accept"] = "application/json"
    request["X-Apikey"] = wok_key
    req_options = {use_ssl: uri.scheme == "https"}
    response = Net::HTTP.start(uri.hostname, uri.port, req_options) {|x| x.request(request)}
    return JSON.parse(response.body)
  end

  config = YAML.load_file("config.yml")
  unless config['wok_key'] then
    puts "\t ... ... WoK key missing; cannot search"
    exit
  end
  unless args[:max_records] then
    puts "\t ... ... Using default WoK download (1000 articles)"
    args[:max_records] = 1000
  end
  
  curr_record = 1
  dois = []
  while curr_record < args[:max_record] then
    output = url_wrapper(args[:term], curr_record, config['wok_key'])
    if curr_record==1
      if output["QueryResult"]["RecordsFound"] <= args[:max_records]
        puts "Downloading all #{output["QueryResult"]["RecordsFound"]} records found"
      else
        puts "Downloading args[:max_records] of #{output["QueryResult"]["RecordsFound"]} records found"
      end
    end

    papers = output["Data"]["Records"]["records"]["REC"]
    for paper.each do |rec|
      identifiers = rec["dynamic_data"]["cluster_related"]["identifiers"]["identifier"]
      for ientifiers.each do |ident|
        if ident["type"] == "doi" then dois.append(ident["value"]) end
      end
    end

    unless args[:where] then
      puts dois
    else
      puts "Saving (appending) DOIs to #{where}"
      File.open(args[:where], "wa") do |file|
        dois.do {|x| file << "#{x}\n"}
      end
      date_metadata(args[:where])
    end
  end
end

desc "Find journal info for DOIs"
task :bib, [:input, :output, :delay] do |task, args|
  entries = []
  unless args[:delay] then args[:delay] = 2 end
  
  if File.exists? args[:input]
    File.open(args[:input]) do |file|
      file.each do |line|
        url = Addressable::URI.parse(line.chomp).normalize.to_s
        url = "curl -LH \"Accept: text/bibliography; style=bibtex\" https://dx.doi.org/#{url}"
        entries.append(`{url}`)
        sleep(args[:delay])
      end
    end
  else
    puts "Cannot open file #{args[:input]}; exitting"
    exit
  end

  File.open(args[:output], "w") do |file|
    file << "doi \t title \t url \t doi \t volume \t number \t journal \t publisher \t author \t year\n"
    for entries.each do |entry|
      entry.split!(/\{|\}/)
      doi = file[10]; title = file[2]; url = entry[8]
      number = file[12]; volume = file[4]; journal = entry[14]
      publisher = entry[16]; author = entry[18]; year = entry[20]
      file << "#{doi} \t #{title} \t #{url} \t #{doi} \t #{volume} \t #{number} \t #{journal} \t #{publisher} \t #{author} \t #{year}\n"
    end
  end
  date_metadata(args[:where])
end
