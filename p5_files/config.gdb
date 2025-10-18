set breakpoint pending on
set startup-quietly on
set confirm off

file ./levic
break levic::Err::report
commands
	where
end
break levic::InternalError::InternalError
commands
	where
end
break levic::ToDoError::ToDoError
commands
	where
end

define p5
  set args p5_tests/$arg0.levi -c
  run
end
