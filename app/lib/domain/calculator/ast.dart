import 'token.dart';

abstract class ASTNode {
  const ASTNode();
}

class NumberNode extends ASTNode {
  final num value;
  const NumberNode(this.value);
}

class ConstantNode extends ASTNode {
  final String name;
  const ConstantNode(this.name);
}

class UnaryOpNode extends ASTNode {
  final TokenType op;
  final ASTNode operand;
  const UnaryOpNode(this.op, this.operand);
}

class PostfixOpNode extends ASTNode {
  final TokenType op;
  final ASTNode operand;
  const PostfixOpNode(this.op, this.operand);
}

class BinaryOpNode extends ASTNode {
  final TokenType op;
  final ASTNode left;
  final ASTNode right;
  const BinaryOpNode(this.op, this.left, this.right);
}

class FunctionCallNode extends ASTNode {
  final String name;
  final List<ASTNode> args;
  const FunctionCallNode(this.name, this.args);
}
