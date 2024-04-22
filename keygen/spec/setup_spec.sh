Describe 'Setup Script'
  Include './setup.sh'

  # Mock all potentially used commands to prevent any actual system modifications
  Mock 'dpkg-query'
    echo "install ok installed"
  End

  Mock 'sudo'
    echo "sudo $@"
    return 0  # Simulate successful execution
  End

  Mock 'apt-get'
    echo "apt-get $@"
    return 0  # Simulate successful execution
  End

  Mock 'apt'
    echo "apt $@"
    return 0  # Simulate successful execution
  End

  Mock 'pip3'
    echo "pip3 $@"
    return 0  # Simulate successful execution
  End

  Mock 'ln'
    echo "ln $@"
    return 0  # Ensure no actual link is created
  End

  # Ensuring that all apt-related commands are covered
  Mock 'apt-cache'
    echo "apt-cache $@"
    return 0
  End

  It 'checks if essential packages are installed'
    When run source setup.sh
    The output should include "sudo apt update"
    The output should include "apt install -y gcc"
    The status should be success
  End
End

