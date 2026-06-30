val scala3Version = "3.8.4"

lazy val root = project
  .in(file("."))
  .settings(
    name := "nqueens-solver",
    version := "0.1.0-SNAPSHOT",

    scalaVersion := scala3Version,

    libraryDependencies += "org.scalameta" %% "munit" % "1.3.2" % Test,
    libraryDependencies += "com.google.ortools" % "ortools-java" % "9.12.4544"

  )
