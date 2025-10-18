set breakpoint pending on
set confirm off
file ./ac
break leviathan::Err::report
commands
	where
end
break leviathan::ToDoError::ToDoError
commands
	where
end
break leviathan::InternalError::InternalError
commands
	where
end

define t1
  set args p1_tests/$arg0.a -o --
  run
end
