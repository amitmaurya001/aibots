resource "null_resource" "upload_maintenance_page" {
  for_each = var.apex_domains

  provisioner "local-exec" {
    command = "aws s3 cp ${path.module}/templates/maintenance.html s3://${aws_s3_bucket.apex_origin[each.key].id}/maintenance.html"
  }

  depends_on = [aws_s3_bucket_policy.origin_access_identity]
}
