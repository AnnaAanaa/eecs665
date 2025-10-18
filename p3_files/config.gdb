set breakpoint pending on
set confirm off
file ./levic
break levi::Err::report
commands
	where
end
break levi::InternalError::InternalError
commands
	where
end

define p3
  set args p3_tests/$arg0.levi -u --
  run
end
