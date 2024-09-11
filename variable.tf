variable "bucketname" {
  type = string
  default = "myterraformwebsiteone"
  description = "bucket name"
}

variable "images" {
  type    = list(string)
  default = ["slide.webp", "scooter2.webp", "scooter3.webp", "scooter1.avif"]
}