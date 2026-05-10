output "glue_job_name" {
  value = aws_glue_job.sales_etl.name
}

output "glue_database_name" {
  value = aws_glue_catalog_database.this.name
}

output "glue_crawler_name" {
  value = aws_glue_crawler.gold.name
}