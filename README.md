# Gallery Generator

This is a [Jekyll plugin](https://github.com/mojombo/jekyll/wiki/Plugins) that generates galleries from directories full of images. It uses [RMagick](http://rmagick.rubyforge.org/) to create thumbnails. It is forked from [ggreer/jekyll-gallery-generator](https://github.com/ggreer/jekyll-gallery-generator).

This plugin is quite minimalist. It generates galleries with no pagination, no sub-galleries, and no descriptions. [See ggreers gallery](http://geoff.greer.fm/photos/) for an example of what it looks like.

This fork adds support for displaying exif metadata on the gallery pages, and support for descriptions of images and galleries.

![Displaying EXIF metadata](exif-example-img.jpg)

## Dependencies

* [ImageMagick](http://www.imagemagick.org/)
* [RMagick](https://github.com/rmagick/rmagick)
* [exifr](https://github.com/remvee/exifr/)


### Install dependencies on OS X
```bash
brew install imagemagick
sudo gem install rmagick exifr
```

## Usage

```bash
cp gallery_generator.rb jekyll-site/_plugins/
cp gallery_index.html jekyll-site/_layouts/
cp gallery_page.html jekyll-site/_layouts/
```

Copy your image directories into `jekyl-site/photos/`. Here's what my directory structure looks like:

```bash
$ ls jekyll-site/photos
best/          chile_trip/  japan_trip/
$ ls jekyll-site/photos/chile_trip
IMG_1039.JPG  IMG_1046.JPG  IMG_1057.JPG
```

Run `jekyll` and be patient. It can take a while to generate all the thumbnails on the first run. After that, you should have pretty pictures.

## Configuration

This plugin reads several config options from `_config.yml`. The following options are supported (default settings are shown):

```yaml
gallery:
  # path to the gallery
  dir: photos
  # title for gallery index
  title: "Photos"
  # title prefix for gallery page. title=title_prefix+gallery_name
  title_prefix: "Photos: "
  # field to control sorting of galleries for the index page
  # (possible values are: title, date_time, best_image)
  sort_field: "date_time"
  # sizes for thumbnails
  thumbnail_size:
    x: 400
    y: 400
  # image scaling method, can be "fit" or "fill", default is "fit"
  # "fit" resizes the image and preserves aspect ratio
  # "fill" resizes the image and crops the image to the specified size
  # Example: source image size is 1200x600, thumbnail size is 400x400
  # "fit": resulting image will be resized to 400x200
  # "fill": resulting image will be resized to 800x400 and then cropped to 400x400 (center area)
  scale_method: "fit"
  # custom configuration for individual gallery
  # best_image is image for the index page (defaults to last image)
  galleries:
    chile_trip:
      best_image: IMG_1068.JPG
    japan_trip:
      best_image: IMG_0690.JPG
    best:
      best_image: snaileo_gonzales.jpg
```

## Image and Gallery Descriptions
To provide descriptions for galleries and images, create `_data/imagedata.yaml`. 
```yaml
chile_trip:
  description: "Description of Gallery 1"
  IMG_1068.JPG: "Description of the image"
japan_trip:
  # no gallery description here, it is optional!
  IMG_0690.JPG: "Another description"
```
Both the image description and the gallery description are optional.
