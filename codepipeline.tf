resource "aws_codestarconnections_connection" "GR_GitHub" {
  name          = "GR-GitHub-Connection"
  provider_type = "GitHub"

  tags = {
    Name        = "GR GitHub Connection"
    Environment = "Sandbox"
  }

}

resource "aws_s3_bucket" "GR-S3-Bucket" {
  bucket              = "gr-s3-bucket-001"
  object_lock_enabled = true

  tags = {
    Name        = "GR bucket"
    Environment = "Sandbox"
  }
}

resource "aws_iam_role" "GR_codepipeline_role" {
  name = "GR-codepipeline-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "codepipeline.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy" "GR_codepipeline_policy" {
  name = "GR-codepipeline-policy"
  role = aws_iam_role.GR_codepipeline_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = "*"
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

resource "aws_codepipeline" "GRcodepipeline" {
  name     = "GR-codepipeline"
  role_arn = aws_iam_role.GR_codepipeline_role.arn

  artifact_store {
    location = aws_s3_bucket.GR-S3-Bucket.bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        ConnectionArn    = aws_codestarconnections_connection.GR_GitHub.arn
        FullRepositoryId = "gramoscscs/grcodebuild"
        BranchName       = "main"
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]

      configuration = {
        ProjectName = aws_codebuild_project.GR_codebuild_project.name
      }
    }
  }
}

resource "aws_codebuild_project" "GR_codebuild_project" {
  name          = "GR-codebuild-project"
  description   = "GR CodeBuild project"
  build_timeout = "5"

  source {
    type      = "GITHUB"
    location  = "https://github.com/gramoscscs/grcodebuild"
    buildspec = "buildspec.yml"
  }

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "aws/codebuild/standard:4.0"
    type         = "LINUX_CONTAINER"
    environment_variable {
      name  = "GR_EXAMPLE_ENV_VAR"
      value = "gr-example-value"
    }
  }

  service_role = aws_iam_role.GR_codebuild_role.arn
}