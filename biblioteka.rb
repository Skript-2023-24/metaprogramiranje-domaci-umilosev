require "google_drive"

def backup(c, m, prefix="original")
  n = :"#{prefix}_#{m}" # Compute the alias
  c.class_eval { # Because alias_method is private
    alias_method n, m # Make n an alias for m
  }
end

Array.class_eval do
    
    def avg
      return nil if empty?
      sum / length.to_f
    end
    
    def sum
      total = 0
      each do |element|
        if element.is_a?(Numeric)
          total += element
        elsif element.is_a?(String) && element.to_i.to_s == element
          total += element.to_i
        end
      end
      total
    end

    def method_missing(method_name, *args, &block)
        search_term = method_name.to_s
    
        # Check if the search term is present in the array
        if include?(search_term)
          p "#{self[0]} #{search_term}" 
        else
          puts "String '#{search_term}' not found in array."
          return nil
        end
      end
    
    def respond_to_missing?(method_name, include_private = false)
        include?(method_name) || super
    end
  end

class Biblioteka
include Enumerable

    def initialize(spreadsheet_key)
        session = GoogleDrive::Session.from_config('config.json')
        @spreadsheet = session.spreadsheet_by_key(spreadsheet_key)
        @spreadsheet
        @ws = @spreadsheet.worksheets.first
        extend_worksheet_class
    end   

    def extend_worksheet_class
        @headers =  @ws.rows[0]
        ws_class= @ws.class

        #tacka2 
        def row(index)
          @ws.rows[index+1]
        end
        
        #tacka 5
        def [](kolona)
            header_index = @headers.index(kolona)
            return nil unless header_index                
            @ws.rows.map {|row| row[header_index]}   
        end
        
        #tacka 6
        @ws.rows[0].each do |header|
          method_name = header.downcase.gsub(" ", "_")
            define_singleton_method(method_name.to_sym) do
              header_index =  @ws.rows[0].index(header)
              return nil unless header_index
                column =  @ws.rows.map do |row| 
                    value = row[header_index]
                    numeric_value = value.to_i.to_s == value ? value.to_i : value
                end   
            end
        end    
      end
end