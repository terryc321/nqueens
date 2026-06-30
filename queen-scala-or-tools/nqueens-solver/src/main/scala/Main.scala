import com.google.ortools.Loader
import com.google.ortools.sat.{CpModel, CpSolver, CpSolverStatus, IntVar, LinearArgument, LinearExpr}
import scala.reflect.ClassTag


object Main:
  def main(args: Array[String]): Unit =
    // Initialize the underlying native C++ binaries
    Loader.loadNativeLibraries()

    val n = 3000 // Try changing this to 50 or 100!
    val model = CpModel()

    // 1. Create variables: queens(i) represents the row position of the queen in column i
    // Explicitly adding ClassTag[IntVar] ensures Array.tabulate compiles perfectly
    val queens: Array[IntVar] = Array.tabulate(n)(i => 
      model.newIntVar(0, n - 1, s"queen_$i")
    )(using ClassTag(classOf[IntVar]))

    // 2. Constraint: All queens must be in different rows
    // Explicitly cast to an array of the parent interface 'LinearArgument'
    model.addAllDifferent(queens.map(v => v: LinearArgument))

    // 3. Constraints: All queens must be on different diagonals
    // We use LinearExpr.affine(variable, coefficient, offset) to represent (queen + i) and (queen - i)
    val diag1: Array[LinearArgument] = Array.tabulate(n)(i => 
      LinearExpr.affine(queens(i), 1, i)
    )(using ClassTag(classOf[LinearArgument]))

    val diag2: Array[LinearArgument] = Array.tabulate(n)(i => 
      LinearExpr.affine(queens(i), 1, -i)
    )(using ClassTag(classOf[LinearArgument]))
    
    model.addAllDifferent(diag1)
    model.addAllDifferent(diag2)

    // 4. Run the solver engine
    val solver = CpSolver()
    val status = solver.solve(model)

    if status == CpSolverStatus.OPTIMAL || status == CpSolverStatus.FEASIBLE then
      println(s"Successfully solved $n-Queens:")
      for i <- 0 until n do
        val row = solver.value(queens(i))
        println(s"Column $i -> Row $row")
    else
      println("No solution found.")


