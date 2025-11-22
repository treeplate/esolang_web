abstract class Statement {
  String toStringIndent(int indent);
  @override
  String toString() => toStringIndent(0);
}

class ExpressionStatement extends Statement {
  final Expression expr;

  @override
  String toStringIndent(int indent) => ' ' * indent + expr.toString();

  ExpressionStatement(this.expr);
}

abstract class Expression {}

/// used for ast to represent error with parsing expression
class PlaceholderExpression extends Expression {
  @override
  String toString() {
    return '<invalid expression>';
  }
}

class Program {
  final List<Statement> program;

  Program({required this.program});
}
