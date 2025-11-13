variable "region" {
  type = string
  default = "ap-south-1"
}
variable "server_http_port" {
  description = "The port for the web server."
  type        = number
  default     = 8080
}