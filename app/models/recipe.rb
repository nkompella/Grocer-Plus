require 'net/http'
class Recipe < ActiveRecord::Base
    has_and_belongs_to_many :users

    def self.call_api(uri)
        req = Net::HTTP::Get.new(uri)
        res = Net::HTTP.start(uri.hostname, :use_ssl => true) {|http|
            http.request(req)
        }
        return JSON.parse(res.body)
    end
    @have_slept = false
    def self.find_in_api(calories, budget, time)
        base_uri = 'https://api.edamam.com/search'
        meal_types = ['breakfast', 'lunch', 'dinner']
        res = {'items' => []}
        meal_types.each_with_index do |elem, idx|
            uri = URI(base_uri + '?q=' + elem + '&app_id=' + ENV["APP_ID"] + '&app_key=' +  ENV["APP_KEY"] + '&from=0&to=1&calories=' + ((calories / 3) - 100).to_s + '-' + ((calories / 3) + 100).to_s + '&time=' + 1.to_s + '-' + (time / 3).to_s)
            res_json_hash = Recipe.call_api(uri)
            hash_to_append = res_json_hash['hits'][0]['recipe']
            hash_to_append['title'] = res_json_hash['hits'][0]['recipe']['label']
            hash_to_append['calories'] = (res_json_hash['hits'][0]['recipe']['calories'] / res_json_hash['hits'][0]['recipe']['yield']).round(0)
            hash_to_append['readyInMinutes'] = res_json_hash['hits'][0]['recipe']['totalTime'].round(0)
            hash_to_append['price'] = 123.00
            hash_to_append['slot'] = idx+1
            hash_to_append['day'] = 1
            res['items'].append(hash_to_append)
        end
        if not @have_slept
            sleep(60)
            @have_slept = true
        end
        return res



        
    end

    
        
end