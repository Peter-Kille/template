module SequenceServer
  # Module to contain methods for generating sequence retrieval links.
  module Links
    require 'erb'

    include ERB::Util
    alias_method :encode, :url_encode

    TITLE_PATTERN = /(\S+)\s(\S+)/
    ID_PATTERN = /(.+?)__(.+?)__(.+)/

    def genomehubs
#      taxa = {}
#      taxa["melitaea_cinxia_core_40_93_1"] = "Melitaea_cinxia"
#      taxa["operophtera_brumata_obru1_core_40_93_1"] = "Operophtera_brumata_obru1"

      if id.match(ID_PATTERN)
        assembly = Regexp.last_match[1]
        type = Regexp.last_match[2]
        accession = Regexp.last_match[3]
      end
      return nil unless accession
 #     return nil unless taxa.has_key?(assembly)
#      assembly = encode taxa[assembly]
      assembly = encode assembly

      accession = encode accession
      colon = ':'
      url = "http://localhost:8881/#{assembly}"
      if type == 'protein' || type == 'aa'
        url = "#{url}/Transcript/ProteinSummary?db=core;p=#{accession}"
      elsif type == 'cds' || type == 'transcript' || type == 'cdna'
        url = "#{url}/Transcript/Summary?db=core;t=#{accession}"
      elsif type == 'gene'
        url = "#{url}/Gene/Summary?db=core;g=#{accession}"
      elsif type == 'contig' || type == 'scaffold' || type == 'chromosome' || type == 'dna'
        sstart = self.coordinates[1][0]
        send = self.coordinates[1][1]
        if sstart > send
          send = self.coordinates[1][0]
          sstart = self.coordinates[1][1]
        end
        url = "#{url}/Location/View?r=#{accession}#{colon}#{sstart}-#{send}"
      end
      {
        :order => 0,
        :title => 'genomehubs',
        :url   => url,
        :icon  => 'fa-external-link'
      }
    end

  end
end

