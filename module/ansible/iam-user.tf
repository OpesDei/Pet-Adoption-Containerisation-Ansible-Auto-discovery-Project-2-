resource "aws_iam_user" "user" {
  name = "ansible-user"
}

resource "aws_iam_access_key" "user-access-key" {
  user = aws_iam_user.user.name
}

resource "aws_iam_group" "group" {
  name = "ansible-group"
}

resource "aws_iam_user_group_membership" "team" {
  user = aws_iam_user.user.name
  groups = [aws_iam_group.group.name]
}

resource "aws_iam_group_policy_attachment" "policy" {
  group      = aws_iam_group.group.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}