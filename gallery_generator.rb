require 'exifr'
require 'RMagick'
include Magick

include FileUtils

$image_extensions = [".png", ".jpg", ".jpeg", ".gif"]

module Jekyll
  class GalleryFile < StaticFile
    def write(dest)
      return false
    end
  end

  class GalleryIndex < Page
    def initialize(site, base, dir, galleries)
      @site = site
      @base = base
      @dir = dir.gsub("source/", "") 
      @name = "index.html"

      self.process(@name)
      self.read_yaml(File.join(base, "_layouts"), "gallery_index.html")
      self.data["title"] = site.config["gallery"]["title"] || "Photos"
      self.data["galleries"] = []
      begin
        sort_field = site.config["gallery"]["sort_field"] || "date_time"
        galleries.sort! {|a,b| b.data[sort_field] <=> a.data[sort_field]}
      rescue Exception => e
        puts e
      end
      galleries.each {|gallery| self.data["galleries"].push(gallery.data)}
    end
  end

  class GalleryPage < Page
    def initialize(site, base, dir, gallery_name)
      @site = site
      @base = base
      @dest_dir = dir.gsub("source/", "")
      @dir = @dest_dir
      @name = "index.html"
      @images = []

      best_image = nil
      max_size_x = 400
      max_size_y = 400
      scale_method = site.config["gallery"]["scale_method"] || "fit"
      begin
        max_size_x = site.config["gallery"]["thumbnail_size"]["x"]
      rescue
      end
      begin
        max_size_y = site.config["gallery"]["thumbnail_size"]["y"]
      rescue
      end
      self.process(@name)
      self.read_yaml(File.join(base, "_layouts"), "gallery_page.html")
      self.data["gallery"] = gallery_name
      gallery_title_prefix = site.config["gallery"]["title_prefix"] || "Photos: "
      gallery_name = gallery_name.gsub("_", " ").gsub(/\w+/) {|word| word.capitalize}
      self.data["name"] = gallery_name
      self.data["title"] = "#{gallery_title_prefix}#{gallery_name}"
      if site.data["imagedata"] != nil && site.data["imagedata"][self.data["gallery"]] != nil && site.data["imagedata"][self.data["gallery"]]["description"] != nil
        self.data["description"] = site.data["imagedata"][self.data["gallery"]]["description"]
      else
        self.data["description"] = ""
      end
      thumbs_dir = "#{site.dest}/#{@dest_dir}/thumbs"

      FileUtils.mkdir_p(thumbs_dir, :mode => 0755)
      Dir.foreach(dir) do |image|
        if image.chars.first != "." and image.downcase().end_with?(*$image_extensions)
          image_data = {}
          image_data["image"] = image
          if site.data["imagedata"] != nil && site.data["imagedata"][self.data["gallery"]] != nil && site.data["imagedata"][self.data["gallery"]][image] != nil
            image_data["caption"] = site.data["imagedata"][self.data["gallery"]][image]
          else
            image_data["caption"] = ""
          end
          begin
            exif = EXIFR::JPEG.new("#{dir}/#{image}")
            image_data["model"] = exif.model
            image_data["exposure"] = exif.exposure_time
            image_data["aperture"] = exif.f_number.to_f
            image_data["iso"] = exif.iso_speed_ratings
            image_data["date"] = exif.date_time
            image_data["focallength"] = exif.focal_length.to_f.round
          rescue
          end
          @images.push(image_data)
          best_image = image
          @site.static_files << GalleryFile.new(site, base, "#{@dest_dir}/thumbs/", image)
          if File.file?("#{thumbs_dir}/#{image}") == false or File.mtime("#{dir}/#{image}") > File.mtime("#{thumbs_dir}/#{image}")
            begin
              m_image = ImageList.new("#{dir}/#{image}")
              m_image.send("resize_to_#{scale_method}!", max_size_x, max_size_y)
              puts "Writing thumbnail to #{thumbs_dir}/#{image}"
              m_image.write("#{thumbs_dir}/#{image}")
            rescue
              puts "error"
              puts $!
            end
            GC.start
          end
        end
      end
      self.data["images"] = @images
      begin
        best_image = site.config["gallery"]["galleries"][self.data["gallery"]]["best_image"]
      rescue
      end
      self.data["best_image"] = best_image
      begin
        self.data["date_time"] = EXIFR::JPEG.new("#{dir}/#{best_image}").date_time.to_i
      rescue
      end
    end
  end

  class GalleryGenerator < Generator
    safe true

    def generate(site)
      unless site.layouts.key? "gallery_index"
        return
      end
      dir = site.config["gallery"]["dir"] || "photos"
      galleries = []
      begin
        Dir.foreach(dir) do |gallery_dir|
          gallery_path = File.join(dir, gallery_dir)
          if File.directory?(gallery_path) and gallery_dir.chars.first != "."
            gallery = GalleryPage.new(site, site.source, gallery_path, gallery_dir)
            gallery.render(site.layouts, site.site_payload)
            gallery.write(site.dest)
            site.pages << gallery
            galleries << gallery
          end
        end
      rescue
        puts $!
      end

      gallery_index = GalleryIndex.new(site, site.source, dir, galleries)
      gallery_index.render(site.layouts, site.site_payload)
      gallery_index.write(site.dest)
      site.pages << gallery_index
    end
  end
end
