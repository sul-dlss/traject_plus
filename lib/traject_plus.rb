require 'traject_plus/version'
require 'traject'

module TrajectPlus
  require 'traject_plus/indexer/step'

  require 'traject_plus/macros'
  require 'traject_plus/extraction'

  require 'traject_plus/csv_reader'
  require 'traject_plus/json_reader'
  require 'traject_plus/xml_reader'

  require 'traject_plus/macros/csv'
  require 'traject_plus/macros/fgdc'
  require 'traject_plus/macros/json'
  require 'traject_plus/macros/mods'
  require 'traject_plus/macros/tei'
  require 'traject_plus/macros/xml'
end
