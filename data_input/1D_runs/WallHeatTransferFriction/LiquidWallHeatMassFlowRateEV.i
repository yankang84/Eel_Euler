#
#####################################################
# Define some global parameters used in the blocks. #
#####################################################
#

[GlobalParams]
###### Boundary conditions: inflow and outflow #######
rhou0_bc = 3600.
T0_bc = 559.15 # 453.
#Po_Outflow = 1.e5
p_bc = 155.e5 # 1.e5
T_bc = 559.15 # 453.

###### Wall heat parameters ######
Hw_fn_name = Hw_fn
#Hw = 5.33e4
#Tw_fn_name = Tw_fn
Tw = 600. # 460.
aw = 0.02983593458 #0.0314159
friction = 0.01
Dh = 0.01179
gravity = '9.8 0. 0.'

###### Other parameters #######
order = FIRST
viscosity_name = ENTROPY
diffusion_name = ENTROPY
isJumpOn = true
Ce = 1.

###### Initial Conditions #######
pressure_init_left = 155.e5#1.e5
pressure_init_right = 155.e5#1.e5
vel_init_left = 0
vel_init_right = 0
temp_init_left = 559.15 # 453
temp_init_right = 559.15 # 453
membrane = 0.5
[]

##############################################################################################
#                                       FUNCTIONs                                            #
##############################################################################################
# Define functions that are used in the kernels and aux. kernels.                            #
##############################################################################################

[Functions]
  [./Hw_fn]
    type = ParsedFunction
    value = H0*sin(pi*x/3.865)*(1-exp(-a*t))  # no space between operators
    vars = 'H0    a '  # beta is a factor to affect the transition duration ~ 1/beta
    vals = '5.33e4    1.'
  [../]

  [./Tw_fn]
    type = ParsedFunction
    value = Tw*exp(-alpha*x/L)*sin(0.5*pi*x/L)+Tmin
    vars = 'Tw    alpha     L    Tmin'
    vals = '600   1.96      3.865.    559.15'
  [../]

  [./area]
    type = ConstantFunction
    value = 7.854e-5
  [../]
[]

#############################################################################
#                          USER OBJECTS                                     #
#############################################################################
# Define the user object class that store the EOS parameters.               #
#############################################################################

[UserObjects]
  [./eos]
    type = StiffenedGasEquationOfState
  	gamma = 2.04
  	Pinf = 8.5e8
  	q = -1151e3
  	Cv = 2069.
  	q_prime = 0. # reference entropy
  [../]

  [./JumpGradPress]
    type = JumpGradientInterface
    variable = pressure_aux
    jump_name = jump_grad_press_aux
  [../]
[]

###### Mesh #######
[Mesh]
  type = GeneratedMesh
  dim = 1
  nx = 200
  xmin = 0
  xmax = 3.865
  block_id = '0'
[]

#############################################################################
#                             VARIABLES                                     #
#############################################################################
# Define the variables we want to solve for: l=liquid phase and g=gas phase.#
#############################################################################

[Variables]
  [./rhoA]
    family = LAGRANGE
    scaling = 1e+0
	[./InitialCondition]
        type = ConservativeVariables1DXIC
        eos = eos
        area = area
	[../]
  [../]

  [./rhouA]
    family = LAGRANGE
    scaling = 1e+0
	[./InitialCondition]
        type = ConstantIC
        value = 0.
	[../]
  [../]

  [./rhoEA]
    family = LAGRANGE
    scaling = 1e+0
	[./InitialCondition]
        type = ConservativeVariables1DXIC
        eos = eos
        area = area
	[../]
  [../]
[]

############################################################################################################
#                                            KERNELS                                                       #
############################################################################################################
# Define the kernels for time dependent, convection and viscosity terms. Same index as for variable block. #
############################################################################################################

[Kernels]

  [./ContTime]
    type = EelTimeDerivative
    variable = rhoA
  [../]

  [./MomTime]
    type = EelTimeDerivative
    variable = rhouA
  [../]

  [./EnerTime]
    type = EelTimeDerivative
    variable = rhoEA
  [../]

  [./Mass]
    type = EelMass
    variable = rhoA
    rhouA_x = rhouA
  [../]

  [./Momentum]
    type = EelMomentum
    variable = rhouA
    rhoA = rhoA
    rhouA_x = rhouA
    rhoEA = rhoEA
    pressure = pressure_aux
    area = area_aux
    eos = eos
  [../]

  [./Energy]
    type = EelEnergy
    variable = rhoEA
    rhoA = rhoA
    rhouA_x = rhouA
    pressure = pressure_aux
    area = area_aux
    eos = eos
  [../]

  [./MassVisc]
    type = EelArtificialVisc
    variable = rhoA
    equation_name = CONTINUITY
    density = density_aux
    velocity_x = velocity_aux
    internal_energy = internal_energy_aux
    norm_velocity = norm_vel_aux
    area = area_aux
  [../]

   [./MomentumVisc]
    type = EelArtificialVisc
    variable = rhouA
    equation_name = XMOMENTUM
    density = density_aux
    velocity_x = velocity_aux
    internal_energy = internal_energy_aux
    norm_velocity = norm_vel_aux
    area = area_aux
  [../]

   [./EnergyVisc]
    type = EelArtificialVisc
    variable = rhoEA
    equation_name = ENERGY 
    density = density_aux
    velocity_x = velocity_aux
    internal_energy = internal_energy_aux
    norm_velocity = norm_vel_aux
    area = area_aux
  [../]
[]

##############################################################################################
#                                       AUXILARY VARIABLES                                   #
##############################################################################################
# Define the auxilary variables                                                              #
##############################################################################################

[AuxVariables]

   [./area_aux]
      family = LAGRANGE
   [../]

   [./velocity_aux]
      family = LAGRANGE
   [../]

   [./density_aux]
      family = LAGRANGE
   [../]

   [./total_energy_aux]
      family = LAGRANGE
   [../]

   [./internal_energy_aux]
      family = LAGRANGE
   [../]

   [./pressure_aux]
      family = LAGRANGE
   [../]

   [./temperature_aux]
    family = LAGRANGE
   [../]

   [./mach_number_aux]
      family = LAGRANGE
   [../]

   [./norm_vel_aux]
    family = LAGRANGE
   [../]

   [./h_aux]
    family = LAGRANGE
   [../]

  [./Tw_aux]
    family = LAGRANGE
  [../]

   [./mu_max_aux]
    family = MONOMIAL
    order = CONSTANT
   [../]

   [./kappa_max_aux]
    family = MONOMIAL
    order = CONSTANT
   [../]

   [./mu_aux]
    family = MONOMIAL
    order = CONSTANT
   [../]

   [./kappa_aux]
    family = MONOMIAL
    order = CONSTANT
   [../]

   [./jump_grad_press_aux]
    family = MONOMIAL
    order = CONSTANT
   [../]
[]

##############################################################################################
#                                       AUXILARY KERNELS                                     #
##############################################################################################
# Define the auxilary kernels for liquid and gas phases. Same index as for variable block.   #
##############################################################################################

[AuxKernels]

  [./AreaAK]
    type = AreaAux
    variable = area_aux
    area = area
  [../]

  [./VelAK]
    type = VelocityAux
    variable = velocity_aux
    rhoA = rhoA
    rhouA = rhouA
  [../]

  [./DensAK]
    type = DensityAux
    variable = density_aux
    rhoA = rhoA
    area = area_aux
  [../]

  [./TotEnerAK]
    type = TotalEnergyAux
    variable = total_energy_aux
    rhoEA = rhoEA
    area = area_aux 
  [../]

  [./IntEnerAK]
    type = InternalEnergyAux
    variable = internal_energy_aux
    rhoA = rhoA
    rhouA_x = rhouA
    rhoEA = rhoEA
    area = area_aux
  [../]

  [./PressAK]
    type = PressureAux
    variable = pressure_aux
    rhoA = rhoA
    rhouA_x = rhouA
    rhoEA = rhoEA
    area = area_aux
    eos = eos
  [../]

  [./TempAK]
    type = TemperatureAux
    variable = temperature_aux
    pressure = pressure_aux
    density = density_aux
    eos = eos
  [../]

  [./MachNumAK]
    type = MachNumberAux
    variable = mach_number_aux
    pressure = pressure_aux
    rhoA = rhoA
    rhouA_x = rhouA
    area = area_aux
    eos = eos
  [../]

  [./NormVelAK]
    type = NormVectorAux
    variable = norm_vel_aux
    x_component = velocity_aux
  [../]

  [./h_aux_AK]
    type = FunctionAux
    variable = h_aux
    function = Hw_fn
    [../]

  [./Tw_aux_AK]
#    type = FunctionAux
#    function = Tw_fn
    type = ConstantAux
    value = 600.
    variable = Tw_aux
  [../]

  [./MuMaxAK]
    type = MaterialRealAux
    variable = mu_max_aux
    property = mu_max
  [../]

  [./KappaMaxAK]
    type = MaterialRealAux
    variable = kappa_max_aux
    property = kappa_max 
  [../]

   [./MuAK]
    type = MaterialRealAux
    variable = mu_aux
    property = mu
   [../]

   [./KappaAK]
    type = MaterialRealAux
    variable = kappa_aux
    property = kappa
   [../]

[]

##############################################################################################
#                                       MATERIALS                                            #
##############################################################################################
# Define functions that are used in the kernels and aux. kernels.                            #
##############################################################################################

[Materials]
#active = ''
  [./EntViscMat]
    type = ComputeViscCoeff
    block = '0'
    velocity_x = velocity_aux
    pressure = pressure_aux
    density = density_aux
    norm_velocity = norm_vel_aux
    jump_grad_press = jump_grad_press_aux
    jump_grad_vel = jump_grad_vel_aux
    eos = eos
#    pressure_PPS_name = AveragePressure
#    velocity_PPS_name = MaxVelocity
  [../]

[]

##############################################################################################
#                                     PPS                                                    #
##############################################################################################
# Define functions that are used in the kernels and aux. kernels.                            #
##############################################################################################
[Postprocessors]
  [./MaxVelocity]
    type = NodalMaxValue
    variable = velocity_aux
  [../]

  [./AveragePressure]
    type = ElementAverageValue
    variable = pressure_aux
  [../]
[]

##############################################################################################
#                               BOUNDARY CONDITIONS                                          #
##############################################################################################
# Define the functions computing the inflow and outflow boundary conditions.                 #
##############################################################################################
[BCs]
  #active = ' '
  [./ContInflowDBC]
    type = EelMassInflowBC
    variable = rhoA
    equation_name = CONTINUITY
    pressure = pressure_aux
    area = area_aux
    eos = eos
    boundary = 'left'
  [../]

  [./ContOutflowDBC]
    type = EelStaticPandTBC
    variable = rhoA
    equation_name = CONTINUITY
    rhoA = rhoA
    rhouA_x = rhouA
    rhoEA = rhoEA
    area = area_aux
    eos = eos
    boundary = 'right'
  [../]

  [./MomInflowDBC]
    type = EelMassInflowBC
    variable = rhouA
    equation_name = XMOMENTUM
    pressure = pressure_aux
    area = area_aux
    eos = eos
    boundary = 'left'
  [../]

  [./MomOutflowDBC]
    type = EelStaticPandTBC
    variable = rhouA
    equation_name = XMOMENTUM
    rhoA = rhoA
    rhouA_x = rhouA
    rhoEA = rhoEA
    area = area_aux
    eos = eos
    boundary = 'right'
  [../]

  [./EnergyInflowDBC]
    type = EelMassInflowBC
    variable = rhoEA
    equation_name = ENERGY
    pressure = pressure_aux
    area = area_aux
    eos = eos
    boundary = 'left'
  [../]

  [./EnergyOutflowDBC]
    type = EelStaticPandTBC
    variable = rhoEA
    equation_name = ENERGY
    rhoA = rhoA
    rhouA_x = rhouA
    rhoEA = rhoEA
    area = area_aux
    eos = eos
    boundary = 'right'
  [../]
[]

##############################################################################################
#                                  PRECONDITIONER                                            #
##############################################################################################
# Define the functions computing the inflow and outflow boundary conditions.                 #
##############################################################################################

[Preconditioning]
  active = 'FDP_Newton'
  [./FDP_Newton]
    type = FDP
    full = true
    petsc_options = '-snes_mf_operator -snes_ksp_ew'
    petsc_options_iname = '-mat_fd_coloring_err  -mat_fd_type  -mat_mffd_type'
    petsc_options_value = '1.e-12       ds             ds'
  [../]
[]

##############################################################################################
#                                     EXECUTIONER                                            #
##############################################################################################
# Define the functions computing the inflow and outflow boundary conditions.                 #
##############################################################################################

[Executioner]
  type = Transient
  string scheme = 'bdf2'
  #num_steps = 40
  end_time = 30.
  dt = 1e-2
  [./TimeStepper]
    type = FunctionDT
    time_t =  '0     3.'
    time_dt = '1.    1.'
  [../]
  dtmin = 1e-9
  #dtmax = 1e-5
  l_tol = 1e-8
  nl_rel_tol = 1e-6
  nl_abs_tol = 1e-6
  l_max_its = 50
  nl_max_its = 30
  [./Quadrature]
    type = GAUSS # TRAP
    order = SECOND
  [../]
[]

##############################################################################################
#                                        OUTPUT                                              #
##############################################################################################
# Define the functions computing the inflow and outflow boundary conditions.                 #
##############################################################################################

[Outputs]
  file_base = LiquidWallHeatMassFlowEVn200
  output_initial = true
  interval = 1
  exodus = true
  postprocessor_screen = false
  perf_log = true
[]
