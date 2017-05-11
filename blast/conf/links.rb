module SequenceServer
  # Module to contain methods for generating sequence retrieval links.
  module Links
    require 'erb'

    include ERB::Util
    alias_method :encode, :url_encode

    TITLE_PATTERN = /(\S+)\s(\S+)/
    ID_PATTERN = /(.+?)__(.+?)__(.+)/

    def sequence_viewer
      accession  = encode self.accession
      database_ids = encode querydb.map(&:id).join(' ')
      url = "geet_sequence/?sequence_ids=#{accession}" \
            "&database_ids=#{database_ids}"

      {
        :order => 0,
        :url   => url,
        :title => 'Sequence',
        :class => 'view-sequence',
        :icon  => 'fa-eye'
      }
    end

    def fasta_download
      accession  = encode self.accession
      database_ids = encode querydb.map(&:id).join(' ')
      url = "get_sequence/?sequence_ids=#{accession}" \
            "&database_ids=#{database_ids}&download=fasta"

      {
        :order => 1,
        :title => 'FASTA',
        :url   => url,
        :class => 'download',
        :icon  => 'fa-download'
      }
    end

    def genomehubs
      taxa = {}
      taxa["acanthocheilonema_viteae_nAv1_core_32_85_1"] = "Acanthocheilonema_viteae_nAv1"
      taxa["setaria_labiatopapillosa_nsl1x1_core_32_85_1"] = "Setaria_labiatopapillosa_nsl1x1"

      if title.match(TITLE_PATTERN)
        assembly = Regexp.last_match[1]
        type = Regexp.last_match[2]
        accession = id
      elsif id.match(ID_PATTERN)
        assembly = Regexp.last_match[1]
        type = Regexp.last_match[2]
        accession = Regexp.last_match[3]
      end
      return nil unless accession
      return nil unless taxa.has_key?(assembly)
      assembly = encode taxa[assembly]

      accession = encode accession
      colon = ':'
      url = "http://ensembl.genomehubs.org/#{assembly}"
      if type == 'protein' || type == 'aa'
        url = "#{url}/Transcript/ProteinSummary?db=core;p=#{accession}"
      elsif type == 'cds' || type == 'transcript'
        url = "#{url}/Transcript/Summary?db=core;t=#{accession}"
      elsif type == 'gene'
        url = "#{url}/Gene/Summary?db=core;g=#{accession}"
      elsif type == 'contig' || type == 'scaffold' || type == 'chromosome'
        subjstart = self.subjstart
        subjend = self.subjend
        if subjstart > subjend
          subjend = self.subjstart
          subjstart = self.subjend
        end
        url = "#{url}/Location/View?r=#{accession}#{colon}#{subjstart}-#{subjend}"
      end
      {
        :order => 2,
        :title => 'genomehubs',
        :url   => url,
        :icon  => 'fa-external-link'
      }
    end

  end
end

