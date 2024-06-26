subroutine dynamics3
!===================================================================C
!
!  Driver for solvent dynamics on (multiple) two-dimensional
!  vibronic free energy surfaces. Based on 4-state PCET model.
!  Gating coordinate is assumed to be fixed (will be alleviated
!  in later versions).
!
!  OPTIONS:
!
!  MDQT - employ Tully's surface hopping algorithm to incorporate
!         non-adiabatic transitions between vibronic states
!         (otherwise classical dynamics on a single vibronic
!         free energy surface is simulated)
!
!  ADIAB - move on adiabatic electron/proton vibrational free energy surfaces
!
!  DIAB2 - move on the ET diabatic electron/proton vibrational free energy surfaces
!
!  DIAB4 - move on the diabatic electron/proton vibrational free energy surfaces
!
!  KG=<int> - index of the grid point along the gating coordinate
!             (it is assumed that the gating coordinate is frozen
!             during the dynamics). The default is KG=1 which implies
!             that the number of grid points along the gating coordinate
!             is also NPNTSG=1 (gating distance is fixed at the values
!             from the input geometry). Otherwise KG must be smaller
!             than NPNTSG.
!
!  ISTATE=<N> - index of the occupied adiabatic vibronic state
!               (1 for ground state) at t=0.
!
!  PURESTATE - the initial density matrix always corresponds to a pure state
!
!  FCSTATE=<N> - index of the initially occupied DIABATIC electronic state
!                ("1" for 1a, "2" for 1b, "3" for 2a, "4" for 2b).
!                The shape of the initial proton wavepacket (specified
!                in the keywords WPFREQ, WPPOS, and WPSTATE) is calculated
!                for a harmonic potential and then its product with the diabatic
!                electronic state (specified in FCSTATE) is expanded in terms of
!                the adiabatic vibronic states. The squares of the expansion
!                coefficients are regarded as the probabilities of the
!                initial populations of the adiabatic vibronic states.
!
!  WPPOS=<position> - center of the harmonic potential for the initial proton
!                     wavepacket relative to the center of the PT interface (Angstrom).
!
!  WPFREQ=<freq> - frequency (cm^-1) of the harmonic potential for the initial
!                  proton wavepacket.
!
!  WPSTATE=<N> - quantum number for the initial proton wavepacket
!                (1 for ground state which is also a default value).
!
!  PUMP=<energy> - energy of the initial laser pulse
!                 (center of the spectral lineshape, in eV)
!
!  PUMPWIDTH=<width> - full width at half maximum (FWHM) of the pump laser spectrum
!
!  PUMPSHAPE=<key> - spectral lineshape of the pump laser pulse
!
!            RECTANGULAR - rectangular lineshape
!            LORENTZIAN  - Lorentzian lineshape   (default)
!            GAUSSIAN    - GAUSSIAN lineshape
!
!
!  NOWEIGHTS - do not calculate the evb weights along the trajectory (default is YES)
!
!  TRANSFORM - initial values of solvent coordinates are given in the
!              rotated and scaled frame (z1,z2).
!
!  ZP0=<float> - center of the initial distribution along ZP (or z1) coordinate
!
!  ZE0=<float> - center of the initial distribution along ZE (or z2) coordinate
!
!  SPECTRUM=<string> - output vibronic spectrum to the external file
!                      (default filename is vibronic_spectrum.dat)
!
!  CONVOLUTION=<key> - calculate and output the convoluted vibronic spectrum
!                      (external file name is vibronic_spectrum_Xconv.dat
!                       where X is "l" for Lorentzian and "g" for Gaussian)
!
!              LORENTZIAN - Lorentzian convolution
!              GAUSSIAN   - Gaussian convolution
!
!  LINEWIDTH=<float> - vibronic linewidth in eV (default is 0.05 eV)
!
!  NSTATES=<int> - number of states to include in dynamics
!
!  TRAJOUT=<string> - name of the output files with trajectory data
!                     (default filename "trajectory_n.dat" where n is the
!                     trajectory index starting from 1)
!
!  SEED=<int> - random seed for RAN2NR random number generator.
!               (if SEED=0 then clock will be used to generate seed)
!               Default value is generated using the current time.
!
!  DUNISEEDS=i/j/k/l - random seeds for DUNI random number generator.
!               (if DUNISEEDS=CLOCK then clock will be used to generate seeds)
!
!  RESET_RANDOM - reset the ran2nr() sequence for each trajectory
!
!  NTRAJ=<int> - number of trajectories to generate (default is 1)
!
!  EPSMODEL=<KEY> - dielectric relaxation model (no defaults!).
!
!            DEBYE - Simple Debye relaxation model
!                    (overdamped Langevin dynamics).
!                    Not compatible with MDQT option!
!
!            ONODERA - Onodera model with short time correction
!                      (ordinary Langevin dynamics).
!
!                   Note that the parameters of the corresponding dielectric
!                   function must be specified within the SOLVENT keyword.
!
!  TSTEP=<float> - timestep for solvent dynamics in picoseconds (default=0.0005)
!
!  NSTEPS=<int> - number of steps (length of the trajectory)
!
!  NQSTEPS=<int> - number of TDSE steps per classical step in MDQT
!
!  MAXNQSTEPS=<int> - maximum number of TDSE steps per classical step in MDQT
!
!  INTERPOLATION=<KEY> - interpolation scheme for TDSE
!
!            LINEAR - linear interpolation of the nonadiabatic coupling term
!                     between t and t+dt (default)
!
!            QUADRATIC - quadratic interpolation of the nonadiabatic coupling term
!                        using values at t, t+dt/2, t+dt
!
!  NDUMP=<int> - trajectory output frequency (every NDUMP steps)
!
!  NDUMP6=<int> - trajectory screen output frequency (every NDUMP6 steps)
!
!  NDUMP777=<int> - populations and coherences output frequency
!                   (every NDUMP777 steps; no output if NDUMP777=0, default)
!
!  T=<float> - temperature in K
!
!  RESTART[=<file>] - restart trajectories (and random number sequences)
!                     File (default name is dynamics_checkpoint) must be
!                     present and not empty.
!
!  PHASE - Phase correction algorithm
!          [N. Shenvi, J. E. Subotnik, and W. Yang, JCP 135, 024101 (2011)]
!
!  AFSSH - Decoherence algorithm, Augmented Fewest Switches Surface Hopping (AFSSH)
!                [N. Shenvi, J. E. Subotnik, 2012, original algorithm]
!
!  COLLAPSE_REGION_COUPLING - A simple decoherence algorithm: wavefunction is collapsed
!                             to occupied state each time the trajectory leaves the interaction
!                             region defined by the cutoff value for the magnitude of the largest
!                             nonadiabatic coupling vector
!
!  COUPLING_CUTOFF=<float> - cutoff for the magnitude of nonadiabatic coupling vector
!
!  !!!COUPLE - couple TDSE to EOM for moments in decoherence algorithm (Eq.18),
!  !!!         Augmented Fewest Switches Surface Hopping (AFSSH) [N. Shenvi, J. E. Subotnik, 2012]
!  !!! (abandoned because this method yields non-positive-definite density matrix)
!
!  ADJUST_ALONG_MOMENTS - adjust velocities along the difference of vectors of moments in decoherence algorithm,
!           Augmented Fewest Switches Surface Hopping (AFSSH-0) [N. Shenvi, J. E. Subotnik, 2011]
!
!  IDS - "Instantaneous Decoherence fror Succesful Hops" decoherence algorithm
!
!  IDA - "Instantaneous Decoherence fror Any Hops" decoherence algorithm
!
!  GEDC - Granucci's Energy-based Decoherence Correction (with C = 1, E0 = 0.1 a.u.)
!
!-------------------------------------------------------------------
!
!  $Author: souda $
!  $Date: 2012-04-06 22:38:46 $
!  $Revision: 5.19 $
!  $Log: not supported by cvs2svn $
!  Revision 5.18  2012/03/13 22:07:59  souda
!  changes related to new solvent models (Onodera-2 and Debye-2)
!
!  Revision 5.17  2011/06/03 05:05:45  souda
!  Kinetic energy components are calculated and added to the trajectory data
!
!  Revision 5.16  2011/04/13 23:49:48  souda
!  Minor restructuring of modules and addition of LAPACK diagonalization wrappers
!
!  Revision 5.15  2011/03/28 21:34:53  souda
!  List of additions:
!  (1) keyword DUNISEEDS for manual input of random seeds for DUNI generator;
!  (2) initialization of random seeds for both RAN2NR and DUNI from the clock;
!  (3) restarting the dynamic trajectories (checkpoint file dynamics_checkpoint)
!
!  Revision 5.14  2011/03/01 23:55:18  souda
!  Variable timestep for quantum propagation implemented (thanks to Sharon) -
!  that fixes the problems with the conservation of the norm of the time-dependent wavefunction.
!
!  Revision 5.13  2011/02/25 19:11:25  souda
!  Now using a separate set of dielectric constant for solvent dynamics.
!
!  Revision 5.12  2011/02/24 00:54:12  souda
!  - changes related to the generation of the initial state after Franck-Condon excitation;
!  - additional keyword PURESTATE for setting the initial wavefunction in MDQT as a pure adiabatic state;
!  - initial state in MDQT is a coherent mixture by default now.
!
!  Revision 5.11  2011/02/23 15:18:28  souda
!  disabled dynamic rewriting of trajectory data to standard output
!
!  Revision 5.10  2011/02/23 07:17:21  souda
!  additional printout
!
!  Revision 5.9  2011/02/22 22:01:34  souda
!  Minor rearrangements
!
!  Revision 5.8  2011/02/20 00:58:11  souda
!  Major additions/modifications:
!  (1) precalculation of the proton vibrational basis functions for METHOD=1
!  (2) Franck-Condon initial excitation added to DYNAMICS3
!  (3) addition of the module timers: module_timers.f90 (changes in Makefile!)
!
!  Revision 5.7  2011/02/10 22:58:28  souda
!  minor bug in resetting the counter of vibronic states calculations.
!
!  Revision 5.6  2011/02/09 20:51:41  souda
!  added two subroutines for transformation of velocities
!  (affects only the output of velocities in zp-ze frame)
!
!  Revision 5.5  2011/02/08 00:47:42  souda
!  added: trajectory output for t=0
!
!  Revision 5.4  2010/11/10 21:14:21  souda
!  Last addition/changes. IMPORTANT: Solvation keyword is back to SOLV( for compatibility reasons
!
!  Revision 5.3  2010/11/04 22:43:08  souda
!  Next iteration... and two additional Makefiles for building the code with debug options.
!
!  Revision 5.2  2010/10/28 21:29:35  souda
!  First (working and hopefully bug-free) source of PCET 5.x
!
!  Revision 5.1  2010/10/26 21:06:20  souda
!  new routines/modules
!
!===================================================================C

   use pardim
   use keys
   use cst
   use timers
   use strings
   use solmat
   use control
   use control_dynamics
   use random_generators
   use quantum
   use geogas, only: iptgas, xyzgas
   use parsol
   use laser
   use propagators_3d
   use feszz_3d, only: reset_feszz3_counter

   implicit none

   character(len=1024) :: options
   character(len=  80) :: fname
   character(len=  15) :: zpedim="kcal/mol      "
   character(len=  15) :: z12dim="(kcal/mol)^1/2"
   character(len=   5) :: mode_dyn
   character(len=   6) :: traj_suffix
   character(len=  20) :: str

   character(len=3), dimension(2) :: iset_char_diab2=(/"1ab","2ab"/)
   character(len=2), dimension(4) :: iset_char_diab4=(/"1a","1b","2a","2b"/)

   logical :: adiab, diab2, diab4, weights
   logical :: switch=.false.
   logical :: success=.false.
   logical :: transform=.false.
   logical :: pure=.true.
   logical :: pump=.false.
   logical :: fcdia=.false.
   logical :: purestate=.false.

   logical :: interaction_region_prev=.false.
   logical :: interaction_region=.false.

   logical :: reset_random=.false.

   integer :: nstates_dyn, nzdim_dyn, ielst_dyn, iseed_inp, iset_dyn
   integer :: initial_state=-1, iground=1, idecoherence=0
   integer :: istate, new_state, ndump6, ndump777, pump_s
   integer :: number_of_skipped_trajectories=0
   integer :: number_of_failed_trajectories=0
   integer :: itraj_start=1
   integer :: ntraj_valid
   integer :: nqsteps_var

   integer :: ikey, ioption, ioption2, ioption3, kg0, ifrom, ito
   integer :: islash1, islash2, islash3, idum1, idum2, idum3, idum4
   integer :: ioutput, lenf, ispa, idash, icount
   integer :: itraj, istep, iqstep, k, itmp, itmp1
   integer :: number_of_switches=0, number_of_rejected=0
   integer :: itraj_channel=11

   real(kind=8) :: sigma, sigma1, sigma2, sample, population_current
   real(kind=8) :: wf_norm, zmom1_norm, zmom2_norm, pzmom1_norm, pzmom2_norm
   real(kind=8) :: zeit_start, zeit_end, zeit_total, traj_time_start, traj_time_end
   real(kind=8) :: zeit, zeit_prev
   real(kind=8) :: zeitq, zeitq_prev
   real(kind=8) :: z1, z2, zp, ze, vz1, vz2, vzp, vze, z10, z20, zp0, ze0, y1, y2
   real(kind=8) :: ekin, ekin1, ekin2, ekin_prev, ekinhalf1, ekinhalf2, efes
   real(kind=8) :: vz1_prev, vz2_prev
   real(kind=8) :: pump_e, pump_w, vib_linewidth
   real(kind=8) :: qtstep_var

   adiab   = .true.
   diab2   = .false.
   diab4   = .false.
   weights = .true.

   !~~~~~~~~~~~~~~
   ! Print banner
   !~~~~~~~~~~~~~~
   write(6,*)
   write(6,'("================================================================")')
   write(6,'("              SOLVENT DYNAMICS MODULE (optional MDQT)           ")')
   write(6,'("         (two solvent coordinates + fixed gating distance)      ")')
   write(6,'("================================================================"/)')

   !~~~~~~~~~~~~~~~~~
   ! Extract options
   !~~~~~~~~~~~~~~~~~

   ikey = index(keywrd,' DYNAMICS3(')

   if (ikey.eq.0) then
      write(*,'(/1x,"*** (in DYNAMICS3): You MUST specify options for DYNAMICS3 keyword ***"/)')
      call clean_exit
   else
      call getopt(keywrd,ikey+11,options)
   endif

   !~~~~~~~~~~~~~~~~~~~
   ! Gating coordinate
   !~~~~~~~~~~~~~~~~~~~

   ioption = index(options," KG=")
   
   if (ioption.ne.0) then
      kg0 = reada(options,ioption+4)
      if (kg0.gt.npntsg) kg0 = npntsg/2
   else
      kg0 = 1
   endif

   if (npntsg.eq.1) then
      kg0 = 1
      write(6,'(1x,"The gating distance is fixed at the value from the input geometry: ",f10.3," A"/)') abs(xyzgas(1,iptgas(3)) - xyzgas(1,iptgas(1)))
   else
      if (kg0.ge.1.and.kg0.le.npntsg) then
         write(6,'(1x," The gating distance is fixed at the value: ",f10.3," A (grid point #",i3,")"/)') glist(kg0),kg0
      else
         write(6,'(1x," The specified gating grid point #",i3," is outside the allowed range (1,",i3,")"/)') kg0,npntsg
         call clean_exit
      endif
   endif

   !~~~~~~~~~~~~~
   ! Temperature
   !~~~~~~~~~~~~~

   ioption = index(options," T=")
   if (ioption.ne.0) then
      temp = reada(options,ioption+3)
   else
      temp = 300.d0
   endif

   write(6,'(1x,"Temperature: ",f10.3," K"/)') temp

   !~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   ! Dielectric relaxation model
   !~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

   ioption = index(options,' EPSMODEL=')

   if (ioption.ne.0) then

      !-- extract the keyword for the model
      ispa = index(options(ioption+10:),space)
      solvent_model = options(ioption+10:ioption+ispa+8)
      write(6,'(/1x,"Dielectric model for dynamical calculations: ",a)') trim(solvent_model)

      if (solvent_model.eq."DEBYE") then
         write(6,'(1x,"(Overdamped solvent dynamics with a single relaxation period)")')
      elseif (solvent_model.eq."DEBYE2") then
         write(6,'(1x,"(Overdamped solvent dynamics with two relaxation periods)")')
      elseif (solvent_model.eq."ONODERA") then
         write(6,'(1x,"(Solvent dynamics with a single relaxation period and effective solvent mass)")')
      elseif (solvent_model.eq."ONODERA2") then
         write(6,'(1x,"(Solvent dynamics with two relaxation periods and effective solvent mass)")')
      else
         write(6,'(1x,"(UNKNOWN model: abort calculation)")')
         call clean_exit
      endif

   else

      solvent_model = "DEBYE"
      write(6,'(/1x,"Dielectric model for dynamical calculations (default): ",a)') trim(solvent_model)
      write(6,'(1x,"(Overdamped solvent dynamics with a single relaxation period)")')

   endif


   !~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   ! Parameters of the dielectric relaxation model
   !~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

   write(6,'(/1x,"Parameters of the dielectric function ",a/)') trim(solvent_model)

   if (solvent_model.eq."DEBYE") then

      ioption = index(options,' TAUD=')
      if (ioption.ne.0) then
         taud = reada(options,ioption+6)
      else
         write(*,'(/1x,"*** (in DYNAMICS): You MUST specify TAUD= option for DEBYE model ***"/)')
         call clean_exit
      endif

      !ioption = index(options,' EPS0=')
      !if (ioption.ne.0) then
      !   eps0_dyn = reada(options,ioption+6)
      !else
      !   write(*,'(/1x,"*** (in DYNAMICS): You MUST specify EPS0= option for DEBYE model ***"/)')
      !   call clean_exit
      !endif

      eps0_dyn = eps0

      !ioption = index(options,' EPS8=')
      !if (ioption.ne.0) then
      !   eps8_dyn = reada(options,ioption+6)
      !else
      !   write(*,'(/1x,"*** (in DYNAMICS): You MUST specify EPS8= option for DEBYE model ***"/)')
      !   call clean_exit
      !endif

      eps8_dyn = eps8

      call set_debye_model_parameters()
      write(6,'(1x,"Static dielectric constant EPS0         ",f15.6)')  eps0_dyn
      write(6,'(1x,"Optical dielectric constant EPS_inf     ",f15.6)')  eps8_dyn
      write(6,'(1x,"Inverse Pekar factor f_0                ",f15.6)')  f0
      write(6,'(1x,"Debye relaxation time TAUD (ps):        ",f15.6)')  taud
      write(6,'(1x,"Longitudianl relaxation time TAUL (ps): ",f15.6)')  taul
      write(6,'(1x,"Effective masses of the solvent (ps^2): ",2f15.6)') effmass1, effmass2

   elseif (solvent_model.eq."DEBYE2") then

      ioption = index(options,' TAU1=')
      if (ioption.ne.0) then
         tau1 = reada(options,ioption+6)
      else
         write(*,'(/1x,"*** (in DYNAMICS): You MUST specify TAU1= option for DEBYE2 model ***"/)')
         call clean_exit
      endif

      ioption = index(options,' TAU2=')
      if (ioption.ne.0) then
         tau2 = reada(options,ioption+6)
      else
         write(*,'(/1x,"*** (in DYNAMICS): You MUST specify TAU2= option for DEBYE2 model ***"/)')
         call clean_exit
      endif

      ioption = index(options,' EPS1=')
      if (ioption.ne.0) then
         eps1_dyn = reada(options,ioption+6)
      else
         write(*,'(/1x,"*** (in DYNAMICS): You MUST specify EPS1= option for DEBYE2 model ***"/)')
         call clean_exit
      endif

      !ioption = index(options,' EPS0=')
      !if (ioption.ne.0) then
      !   eps0_dyn = reada(options,ioption+6)
      !else
      !   write(*,'(/1x,"*** (in DYNAMICS): You MUST specify EPS0= option for DEBYE2 model ***"/)')
      !   call clean_exit
      !endif

      eps0_dyn = eps0

      !ioption = index(options,' EPS8=')
      !if (ioption.ne.0) then
      !   eps8_dyn = reada(options,ioption+6)
      !else
      !   write(*,'(/1x,"*** (in DYNAMICS): You MUST specify EPS8= option for DEBYE2 model ***"/)')
      !   call clean_exit
      !endif

      eps8_dyn = eps8

      call set_debye2_model_parameters()
      write(6,'(1x,"Static dielectric constant EPS0         ",f15.6)') eps0_dyn
      write(6,'(1x,"Optical dielectric constant EPS_inf     ",f15.6)') eps8_dyn
      write(6,'(1x,"Additional dielectric constant EPS1     ",f15.6)') eps1_dyn
      write(6,'(1x,"Inverse Pekar factor f_0                ",f15.6)') f0
      write(6,'(1x,"First  relaxation time TAU1 (ps):       ",f15.6)') tau1
      write(6,'(1x,"Second relaxation time TAU2 (ps):       ",f15.6)') tau2
      write(6,'(1x,"Longitudianl relaxation time TAUL (ps): ",f15.6)') taul
      write(6,'(1x,"Effective masses of the solvent (ps^2): ",2f15.6)') effmass1, effmass2

   elseif (solvent_model.eq."ONODERA") then

      ioption = index(options,' TAUD=')
      if (ioption.ne.0) then
         taud = reada(options,ioption+6)
      else
         write(*,'(/1x,"*** (in DYNAMICS): You MUST specify TAUD= option for ONODERA model ***"/)')
         call clean_exit
      endif

      ioption = index(options,' TAU0=')
      ioption2 = index(options,' EFFMASS=')

      if (ioption.ne.0) then

         tau0 = reada(options,ioption+6)
         if (tau0.eq.0.d0) then
            write(*,'(/1x,"*** (in DYNAMICS3): Use EFFMASS option instead of setting TAU0 to zero ***"/)')
            call clean_exit
         endif

      elseif (ioption2.ne.0) then

         tau0 = 0.d0
         ikey = ioption2 + 9
         ispa = index(options(ikey:),space)
         islash1 = index(options(ikey:ikey+ispa-1),'/')
         if (islash1.eq.0) then
            effmass1 = reada(options,ikey)
            effmass2 = effmass1
         else
            effmass1 = reada(options(ikey:ikey+islash1-2),1)
            effmass2 = reada(options,ikey+islash1)
         endif

      else

         write(*,'(/1x,"*** (in DYNAMICS3): You MUST specify either TAU0 or EFFMASS option for ONODERA model ***"/)')
         call clean_exit

      endif

      !-- dielectric constants

      !ioption = index(options,' EPS0=')
      !if (ioption.ne.0) then
      !   eps0_dyn = reada(options,ioption+6)
      !else
      !   write(*,'(/1x,"*** (in DYNAMICS): You MUST specify EPS0= option for ONODERA model ***"/)')
      !   call clean_exit
      !endif

      eps0_dyn = eps0

      !ioption = index(options,' EPS8=')
      !if (ioption.ne.0) then
      !   eps8_dyn = reada(options,ioption+6)
      !else
      !   write(*,'(/1x,"*** (in DYNAMICS): You MUST specify EPS8= option for ONODERA model ***"/)')
      !   call clean_exit
      !endif

      eps8_dyn = eps8

      call set_onodera_model_parameters()
      write(6,'(1x,"Static dielectric constant EPS0          ",f15.6)') eps0_dyn
      write(6,'(1x,"Optical dielectric constant EPS_inf      ",f15.6)') eps8_dyn
      write(6,'(1x,"Inverse Pekar factor f_0                 ",f15.6)') f0
      write(6,'(1x,"Debye   relaxation time TAUD (ps)        ",f15.6)') taud
      write(6,'(1x,"Onodera relaxation time TAU0 (ps)        ",f15.6)') tau0
      write(6,'(1x,"Longitudinal relaxation time TAUL  (ps)  ",f15.6)') taul
      write(6,'(1x,"Longitudinal relaxation time TAU0L (ps)  ",f15.6)') tau0l
      write(6,'(1x,"Effective masses of the solvent (ps^2)   ",2f15.6)') effmass1, effmass2

   !-- Onodera model with two relaxation periods
   elseif (solvent_model.eq."ONODERA2") then

      ioption = index(options,' EPS0=')
      if (ioption.ne.0) then
         eps0_dyn = reada(options,ioption+6)
      else
         eps0_dyn = eps0
      endif

      ioption = index(options,' EPS8=')
      if (ioption.ne.0) then
         eps8_dyn = reada(options,ioption+6)
      else
         eps8_dyn = eps8
      endif


      if (index(options,' GLEPARS').eq.0) then

         ioption = index(options,' TAU0=')
         ioption2 = index(options,' EFFMASS=')

         if (ioption.ne.0) then

            tau0 = reada(options,ioption+6)
            if (tau0.eq.0.d0) then
               write(*,'(/1x,"*** (in DYNAMICS3): Use EFFMASS option instead of setting TAU0 to zero ***"/)')
               call clean_exit
            endif

         elseif (ioption2.ne.0) then

            tau0 = 0.d0
            ikey = ioption2 + 9
            ispa = index(options(ikey:),space)
            islash1 = index(options(ikey:ikey+ispa-1),'/')
            if (islash1.eq.0) then
               effmass1 = reada(options,ikey)
               effmass2 = effmass1
            else
               effmass1 = reada(options(ikey:ikey+islash1-2),1)
               effmass2 = reada(options,ikey+islash1)
            endif

         else

            write(*,'(/1x,"*** (in DYNAMICS3): You MUST specify either TAU0 or EFFMASS option for ONODERA-2 model ***"/)')
            call clean_exit

         endif

         ioption = index(options,' TAU1=')
         if (ioption.ne.0) then
            tau1 = reada(options,ioption+6)
         else
            write(*,'(/1x,"*** (in DYNAMICS): You MUST specify TAU1= option for ONODERA-2 model ***"/)')
            call clean_exit
         endif

         ioption = index(options,' TAU2=')
         if (ioption.ne.0) then
            tau2 = reada(options,ioption+6)
         else
            write(*,'(/1x,"*** (in DYNAMICS): You MUST specify TAU2= option for ONODERA-2 model ***"/)')
            call clean_exit
         endif

         ioption = index(options,' EPS1=')
         if (ioption.ne.0) then
            eps1_dyn = reada(options,ioption+6)
         else
            write(*,'(/1x,"*** (in DYNAMICS): You MUST specify EPS1= option for ONODERA-2 model ***"/)')
            call clean_exit
         endif

         call set_onodera2_model_parameters()
         write(6,'(1x,"Static dielectric constant EPS0          ",f15.6)') eps0_dyn
         write(6,'(1x,"Optical dielectric constant EPS_inf      ",f15.6)') eps8_dyn
         write(6,'(1x,"Inverse Pekar factor f_0                 ",f15.6)') f0
         write(6,'(1x,"Additional dielectric constant EPS1      ",f15.6)') eps1_dyn
         write(6,'(1x,"Onodera relaxation time TAU0 (ps)        ",f15.6)') tau0
         write(6,'(1x,"First relaxation time TAU1 (ps)          ",f15.6)') tau1
         write(6,'(1x,"Second relaxation time TAU1 (ps)         ",f15.6)') tau2
         write(6,'(1x,"Effective masses of the solvent (ps^2)   ",2f15.6)') effmass1, effmass2

      else

         !-- parameters of the GLE

         ioption = index(options,' EFFMASS=')

         if (ioption.ne.0) then

            ikey = ioption + 9
            ispa = index(options(ikey:),space)
            islash1 = index(options(ikey:ikey+ispa-1),'/')
            if (islash1.eq.0) then
               effmass1 = reada(options,ikey)
               effmass2 = effmass1
            else
               effmass1 = reada(options(ikey:ikey+islash1-2),1)
               effmass2 = reada(options,ikey+islash1)
            endif

         else

            write(*,'(/1x,"*** (in DYNAMICSET2): You MUST specify EFFMASS= option for ONODERA-2 model ***"/)')
            call clean_exit

         endif

         ioption = index(options,' GAMMA=')
         if (ioption.ne.0) then
            gamma = reada(options,ioption+7)
         else
            write(*,'(/1x,"*** (in DYNAMICSET2): You MUST specify GAMMA= option for ONODERA-2 model ***"/)')
            call clean_exit
         endif

         ioption = index(options,' TAUALPHA=')
         if (ioption.ne.0) then
            taualpha = reada(options,ioption+10)
         else
            write(*,'(/1x,"*** (in DYNAMICSET2): You MUST specify TAUALPHA= option for ONODERA-2 model ***"/)')
            call clean_exit
         endif

         ioption = index(options,' ETA=')
         if (ioption.ne.0) then
            etax = reada(options,ioption+5)
            etay = gamma*taualpha
         else
            write(*,'(/1x,"*** (in DYNAMICSET2): You MUST specify ETA= option for ONODERA-2 model ***"/)')
            call clean_exit
         endif

         write(6,'(1x,"Static dielectric constant EPS0        ",f15.6)') eps0_dyn
         write(6,'(1x,"Optical dielectric constant EPS_inf    ",f15.6)') eps8_dyn
         write(6,'(1x,"Inverse Pekar factor f_0               ",f15.6)') f0
         write(6,'(1x,"Friction coefficient ETA_X (ps)        ",f15.6)') etax
         write(6,'(1x,"Friction coefficient ETA_Y (ps)        ",f15.6)') etay
         write(6,'(1x,"Parameter GAMMA                        ",f15.6)') gamma
         write(6,'(1x,"Friction kernel time scale TAU_A (ps)  ",f15.6)') taualpha
         write(6,'(1x,"Effective masses of the solvent (ps^2) ",2f15.6)') effmass1, effmass2

      endif

      if (effmass1.eq.0.d0.or.effmass2.eq.0.d0) then
         write(*,'(/1x,"*** (in DYNAMICS3): The effective solvent masses MUST NOT BE ZERO, check your input ***"/)')
         call clean_exit
      endif

   endif


   !~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   ! Type of dynamics (classical or MDQT)
   !~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

   if (index(options,' MDQT').ne.0) then

      if (solvent_model.eq."DEBYE".or.solvent_model.eq."DEBYE2") then
         write(6,'(/1x,"MDQT is not compatible with overdamped diffusive dynamics (DEBYE and DEBYE2).")')
         write(6,'( 1x,"Please choose ONODERA or ONODERA2 model for solvent dynamics.")')
         write(6,'( 1x,"Check your input and make up your mind!!! Aborting...")')
         call clean_exit
      endif

      mdqt = .true.
      write(6,'(/1x,"Mixed quantum-classical dynamics on multiple vibronic free energy surfaces.",/,&
                &1x,"Tullys fewest switches surface hopping algorithm (MDQT) will be utilized."/)')

      if (index(options,' PHASE').ne.0) then
         phase_corr = .true.
         write(6,'(/1x,"Phase correction algorithm will be used.",/,&
                   &1x,"[N. Shenvi, J. E. Subotnik, and W. Yang, J. Chem. Phys. 135, 024101 (2011) ]"/)')
      endif

      !-- decoherence options

      idecoherence = 0
      if (index(options,' AFSSH').ne.0) idecoherence = idecoherence + 1
      if (index(options,' COLLAPSE_REGION_COUPLING').ne.0) idecoherence = idecoherence + 1
      if (index(options,' IDS').ne.0) idecoherence = idecoherence + 1
      if (index(options,' IDA').ne.0) idecoherence = idecoherence + 1
      if (index(options,' GEDC').ne.0) idecoherence = idecoherence + 1

      if (idecoherence.gt.0) then

         !-- make sure that only one decoherence option has been chosen
         if (idecoherence.gt.1) then
            write(6,'(/1x,"Only one decoherence option can be specified.")')
            write(6,'( 1x,"Your input contains more then one decoherence option in DYNAMICS2 keyword.")')
            write(6,'( 1x,"Choose one of: AFSSH, COLLAPSE_REGION_COUPLING, IDS, IDA, or GEDC. ")')
            write(6,'( 1x,"Check your input and make up your mind!!! Aborting...")')
            call clean_exit
         endif

         decoherence = .true.

      endif


      if (index(options,' AFSSH').ne.0) then

         if (.not.phase_corr) then

            afssh = .true.
            collapse_region_coupling = .false.
            ids = .false.
            ida = .false.
            gedc = .false.

            ioption = index(options," DZETA=")
            if (ioption.ne.0) then
               dzeta = reada(options,ioption+7)
            else
               dzeta = 1.d0
            endif
            write(6,'(/1x,"Decoherence algorithm (AFSSH) with dzeta =",f8.3," will be used.",/,&
                      &1x,"[B. R. Landry, N. Shenvi, J. E. Subotnik, 2012]"/)') dzeta

            if (index(options," COUPLE").ne.0) then
               decouple = .false.
               write(6,'(/1x,"The TDSE in decoherence algorithm (AFSSH) will be coupled to EOM for the moments (Eq.18)")')
            else
               decouple = .true.
               write(6,'(/1x,"The TDSE in decoherence algorithm (AFSSH) will be decoupled from EOM for the moments (original algorithm)")')
            endif

            if (index(options," ADJUST_ALONG_MOMENTS").ne.0) then
               along_moments = .true.
               write(6,'(/1x,"The adjustment of velocities will be performed along the direction of the difference")')
               write(6,'( 1x,"between the moments of momenta in decoherence algorithm (AFSSH-0)")')
            else
               along_moments = .false.
            endif

         else

            write(6,'(/1x,"In current version decoherence (AFSSH) and phase-correction algorithms are incompatible")')
            write(6,'( 1x,"Your input contains both PHASE and DECOHERENCE options in DYNAMICS3 keyword.")')
            write(6,'( 1x,"Check your input and make up your mind!!! Aborting...")')
            call clean_exit

         endif



      elseif (index(options,' COLLAPSE_REGION_COUPLING').ne.0) then

         collapse_region_coupling = .true.
         afssh = .false.
         ids = .false.
         ida = .false.
         gedc = .false.

         ioption = index(options," COUPLING_CUTOFF=")
         if (ioption.ne.0) then
            coupling_cutoff = reada(options,ioption+17)
         else
            coupling_cutoff = 1.d-5
         endif
         write(6,'(/1x,"Simple decoherence algorithm with collapsing events occuring upon leaving the interaction region")')
         write(6,'( 1x,"The interaction region is defined as region where the largest nonadiabatic coupling")')
         write(6,'( 1x,"is smaller in magnitude than the cutoff value of ",g15.6," (kcal/mol)^{-1/2}"/)') coupling_cutoff


      elseif (index(options,' IDS').ne.0) then

         ids = .true.
         collapse_region_coupling = .false.
         afssh = .false.
         ida = .false.
         gedc = .false.
         write(6,'(/1x,"Instantaneous decoherence algorithm with collapsing events occuring upon succesful hops (IDS)")')


      elseif (index(options,' IDA').ne.0) then

         ida = .true.
         collapse_region_coupling = .false.
         afssh = .false.
         ids = .false.
         gedc = .false.
         write(6,'(/1x,"Instantaneous decoherence algorithm with collapsing events occuring upon any hop (IDA)")')

      elseif (index(options,' GEDC').ne.0) then

         gedc = .true.
         ida = .false.
         collapse_region_coupling = .false.
         afssh = .false.
         ids = .false.
         write(6,'(/1x,"Granucci-s Energy-based Decoherence correction (GEDC) with C=1 and E0=0.1au")')

      endif

   else

      mdqt = .false.
      write(6,'(/1x,"Simulation of classical dynamics on a single vibronic free energy surface (default)."/)')

   endif


   !~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   ! Surface type (ADIAB, DIAB)
   !~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

   if (index(options,' ADIAB').ne.0) then

      mode_dyn  = 'ADIAB'
      adiab = .true.
      diab2 = .false.
      diab4 = .false.
      ielst_dyn = nelst
      iset_dyn = 1
      write(6,'(/1x,"Solvent dynamics on adiabatic free energy surface(s)."/)')

   elseif (index(options,' DIAB2=').ne.0) then

      ioption = index(options,' DIAB2=')
      mode_dyn  = 'DIAB2'
      adiab = .false.
      diab2 = .true.
      diab4 = .false.
      ielst_dyn = 2
      iset_dyn = reada(options,ioption+7)

      if (iset_dyn.eq.1) then
         write(6,'(/1x,"Solvent dynamics on the (1a/1b) ET diabatic surface(s)")')
      elseif (iset_dyn.eq.2) then
         write(6,'(/1x,"Solvent dynamics on the (2a/2b) ET diabatic surface(s)")')
      else
         write(*,'(/1x,"*** (in DYNAMICS): subset in DIAB2 keyword must be 1 or 2 ***"/)')
         call clean_exit
      endif

   elseif (index(options,' DIAB4=').ne.0) then

      ioption = index(options,' DIAB4=')
      mode_dyn  = 'DIAB4'
      adiab = .false.
      diab2 = .false.
      diab4 = .true.
      ielst_dyn = 1
      iset_dyn = reada(options,ioption+7)

      if (iset_dyn.eq.1) then
         write(6,'(/1x,"Solvent dynamics on the diabatic surface(s) within the 1a electronic set")')
      elseif (iset_dyn.eq.2) then
         write(6,'(/1x,"Solvent dynamics on the diabatic surface(s) within the 1b electronic set")')
      elseif (iset_dyn.eq.3) then
         write(6,'(/1x,"Solvent dynamics on the diabatic surface(s) within the 2a electronic set")')
      elseif (iset_dyn.eq.4) then
         write(6,'(/1x,"Solvent dynamics on the diabatic surface(s) within the 2b electronic set")')
      else
         write(*,'(/1x,"*** (in DYNAMICS3): subset in DIAB4 keyword must be 1 or 2 or 3 or 4 ***"/)')
         call clean_exit
      endif

      if (mdqt) then
         write(*,'(/1x,"MDQT in the diabatic representation is not implemented in the current version."/)')
         call clean_exit
      endif

   else

      mode_dyn  = 'ADIAB'
      adiab = .true.
      diab2 = .false.
      diab4 = .false.
      ielst_dyn = nelst
      iset_dyn = 1
      write(6,'(/1x,"Solvent dynamics on adiabatic free energy surface(s)."/)')

   endif

   !~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   ! flag for EVB weights
   !~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   if (index(options,' NOWEIGHTS').ne.0) then
      weights = .false.
      write(6,'(/1x,"EVB weights WILL NOT be calculated along the trajectory."/)')
   endif

   !~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   ! Number of vibronic states to include in dynamics
   !~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

   ioption = index(options," NSTATES=")
   
   if (ioption.ne.0) then
      nstates_dyn = reada(options,ioption+9)
      write(6,'(/1x,"Number of vibronic states to include in dynamics: ",i4/)') nstates_dyn
   else
      nstates_dyn = nelst*nprst
      write(6,'(/1x,"Number of vibronic states to include in dynamics (all states by default): ",i4/)') nstates_dyn
   endif

   !~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   ! Number of trajectories
   !~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

   ioption = index(options," NTRAJ=")
   
   if (ioption.ne.0) then
      ntraj = reada(options,ioption+7)
   else
      ntraj = 1
   endif
   write(6,'(1x,"Number of trajectories to generate: ",i4/)') ntraj

   !~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   ! Timesteps
   !~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

   ioption = index(options," TSTEP=")
   if (ioption.ne.0) then
      tstep = reada(options,ioption+7)
   else
      tstep = 0.0005d0
   endif

   write(6,'(1x,"Timestep for solvent dynamics: ",g15.6," ps"/)') tstep

   !~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   ! Number of steps in each trajectory
   !~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

   ioption = index(options," NSTEPS=")
   
   if (ioption.ne.0) then
      nsteps = reada(options,ioption+8)
      write(6,'(1x,"Number of steps in each trajectory: ",i10/)') nsteps
   else
      nsteps = 100
      write(6,'(1x,"Number of steps in each trajectory (default value): ",i10/)') nsteps
   endif

   !~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   ! Number of steps in TDSE (for MDQT)
   !~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

   if (mdqt) then

      ioption = index(options," NQSTEPS=")
      if (ioption.ne.0) then
         itmp = reada(options,ioption+9)
         write(6,'(1x,"Number of TDSE steps per classical step in MDQT: ",i10/)') itmp
      else
         itmp = 100
         write(6,'(1x,"Number of TDSE steps per classical step in MDQT (default value): ",i10/)') itmp
      endif
      write(6,'(1x,"Timestep for TDSE: ",g15.6," ps"/)') tstep/real(itmp,kind=8)

      ioption = index(options," MAXNQSTEPS=")
      if (ioption.ne.0) then
         itmp1 = reada(options,ioption+12)
         write(6,'(1x,"Maximum number of TDSE steps per classical step in MDQT: ",i10/)') itmp1
      else
         itmp1 = 10000
         write(6,'(1x,"Maximum number of TDSE steps per classical step in MDQT (default value): ",i10/)') itmp1
      endif
      write(6,'(1x,"Minimum timestep for TDSE: ",g15.6," ps"/)') tstep/real(itmp1,kind=8)

      call set_tdse_timestep(itmp,itmp1,tstep)

   endif

   !~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   ! Interpolation scheme for nonadiabatic coupling term in TDSE
   !~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

   if (mdqt) then

      ioption = index(options,' INTERPOLATION=')

      if (ioption.ne.0) then

         !-- extract the keyword for the interpolation scheme
         ispa = index(options(ioption+15:),space)
         interpolation = options(ioption+15:ioption+ispa+13)
         write(6,'(/1x,"Interpolation scheme for the nonadiabatic coupling term in TDSE: ",a)') trim(interpolation)

         if (interpolation.eq."LINEAR") then
            write(6,'(1x,"(linear interpolation using the values at t and t+dt)")')
         elseif (interpolation.eq."QUADRATIC") then
            write(6,'(1x,"(quadratic interpolation using the values at t, t+dt/2, and t+dt)")')
         else
            write(6,'(1x,"(ERROR in DYNAMICS3: UNKNOWN interpolation scheme. Check your input file.)")')
            call clean_exit
         endif

      else

         interpolation = "LINEAR"
         write(6,'(/1x,"Interpolation scheme for the nonadiabatic coupling term in TDSE (default): ",a)') trim(interpolation)
         write(6,'(1x,"(linear interpolation using the values at t and t+dt)")')

      endif

   endif

   !~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   ! Trajectory output frequency (every NDUMP steps)
   !~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

   ioption = index(options," NDUMP=")
   
   if (ioption.ne.0) then
      ndump = reada(options,ioption+7)
      write(6,'(1x,"Dump trajectory data every ",i10," steps"/)') ndump
   else
      ndump = 1
      write(6,'(1x,"Dump trajectory data every single step (default)"/)')
   endif

   !~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   ! Trajectory screen output frequency (every NDUMP6 steps)
   !~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

   ioption = index(options," NDUMP6=")
   
   if (ioption.ne.0) then
      ndump6 = reada(options,ioption+8)
      write(6,'(1x,"Dump trajectory data to screen every ",i10," steps"/)') ndump6
   else
      ndump6 = 0
   endif

   !~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   ! Populations and coherences output frequency (every NDUMP777 steps)
   !~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

   ioption = index(options," NDUMP777=")

   if (ioption.ne.0) then
      ndump777 = reada(options,ioption+10)
      write(6,'(1x,"Dump populations and coherences every ",i10," steps"/)') ndump777
   else
      ndump777 = 0
   endif

   !~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   ! Random seed for RAN2NR (negative to reinitialize)
   !~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

   ioption = index(options," SEED=")
   if (ioption.ne.0) then
      iseed_inp = reada(options,ioption+6)
      call set_random_seed(iseed_inp)
      write(6,'(1x,"Random seed for RAN2NR: ",i6/)') iseed
   else
      !-- use clock to generate random seed
      call set_random_seed()
      write(6,'(1x,"Random seed for RAN2NR was generated based on the clock: ",i6/)') iseed
   endif

   !~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   ! Random seeds for DUNI
   !~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

   ioption = index(options," DUNISEEDS=")
   ioption2 = ioption + 11

   if (ioption.ne.0) then

      if (options(ioption2:ioption2+4).eq."CLOCK") then
      
         !-- set seeds using current time
         call set_duni_random_seeds()
         write(6,'(/1x,"Random seeds for DUNI: from clock:")')

      else

         !-- set seeds manually (from input)

         islash1 = index(options(ioption2:),'/')
         islash2 = index(options(ioption2+islash1:),'/')
         islash3 = index(options(ioption2+islash1+islash2:),'/')
         idum1 = reada(options(ioption2:ioption2+islash1-2),1)
         idum2 = reada(options(ioption2+islash1:ioption2+islash1+islash2-1),1)
         idum3 = reada(options(ioption2+islash1+islash2:ioption2+islash1+islash2+islash3-1),1)
         idum4 = reada(options,ioption2+islash1+islash2+islash3)
         call set_duni_random_seeds(idum1,idum2,idum3,idum4)
         write(6,'(/1x,"Random seeds for DUNI: from input:")')

      endif

   endif

   write(6,'(/1x,"Random seeds for DUNI random number generator:")')
   write(6,'( 1x,"i_seed = ",i6)')  i_seed
   write(6,'( 1x,"j_seed = ",i6)')  j_seed
   write(6,'( 1x,"k_seed = ",i6)')  k_seed
   write(6,'( 1x,"l_seed = ",i6/)') l_seed

   !~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   ! Reset ran2nr() sequence when starting each trajectory
   !~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

   if (index(options,' RESET_RANDOM').ne.0) then
      reset_random = .true.
      write(6,'(/1x,"ran2nr() random sequence will be reset when starting each new trajectory."/)')
   endif

   !~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   ! The solvent coordinate frame used for initial values
   !~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   ioption = index(options,"TRANSFORM")
   if (ioption.ne.0) then
      transform = .true.
   else
      transform = .false.
   endif

   !~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   ! Initial solvent coordinates
   ! (center of the initial distribution)
   !~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

   ioption = index(options,' ZP0=')
   if (ioption.ne.0) then
      ioption = ioption + 5
      zp0 = reada(options,ioption)
   else
      write(*,'(/1x,"*** (in DYNAMICS): You MUST specify ZP0= option for DYNAMICS keyword ***"/)')
      call clean_exit
   endif

   ioption = index(options,' ZE0=')
   if (ioption.ne.0) then
      ioption = ioption + 5
      ze0 = reada(options,ioption)
   else
      write(*,'(/1x,"*** (in DYNAMICS): You MUST specify ZE0= option for DYNAMICS keyword ***"/)')
      call clean_exit
   endif

   if (.not.transform) then
      call zpze_to_z1z2(zp0,ze0,z10,z20)
   else
      z10 = zp0
      z20 = ze0
      call z1z2_to_zpze(z10,z20,zp0,ze0)
   endif

   write(6,'(/1x,"Center of the initial distribution of solvent coordinates:",/,&
   &" ZP(0) = ",F10.3,2X,A," and ZE(0) = ",F10.3,2X,A,/,&
   &" z1(0) = ",F10.3,2X,A," and z2(0) = ",F10.3,2X,A)')&
   &  zp0,zpedim,ze0,zpedim,z10,z12dim,z20,z12dim

   !~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   ! Gating coordinate dynamics (not implemented yet)
   !~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

   !~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   !-- set control variables in the propagators module
   !~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   nzdim_dyn = nprst*ielst_dyn
   call set_mode(mode_dyn,iset_dyn,nstates_dyn,nzdim_dyn,ielst_dyn)

   !~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   !-- Allocate arrays in propagators module
   !~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   call allocate_vibronic_states
   if (mdqt) then
      call allocate_mdqt_arrays
      if (afssh) call allocate_afssh_arrays
   endif
   if (weights) call allocate_evb_weights

   !~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   !-- nature of the initial density matrix
   !   (meaningful only for MDQT dynamics)
   !~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   purestate = index(options,' PURESTATE').ne.0

   !~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   ! Type of the initial condition:
   !
   ! PURE - initial state is a pure vibronic state
   !        specified by the ISTATE keyword
   !
   ! PUMP - initial state is chosen according to the
   !        magnitude of the transition dipole moment
   !        matrix element between the ground state
   !        and the excited state
   !
   ! FCDIA - initial state is a product of the specified
   !         diabatic electronic state (1a, 1b, 2a, 2b)
   !         and harmonic proton vibrational wavepacket
   !         (any state of a harmonic oscillator)
   !
   !~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

   pure  = index(options,' ISTATE=')  .ne. 0
   fcdia = index(options,' FCSTATE=') .ne. 0
   pump  = index(options,' PUMP=')    .ne. 0


   !-- The three options should be mutually exclusive.

   icount = 0
   if (pure)  icount = icount + 1
   if (pump)  icount = icount + 1
   if (fcdia) icount = icount + 1

   if (icount.eq.0) then

      !-- none of the relevant keywords has been specified: default mode "pure" and ISTATE=1

      pure = .true.
      initial_state = 1
      write(6,'(1x,"(Default initial condition) At t=0: Pure ground vibronic adiabatic state.")')

   elseif (icount.gt.1) then

      !-- more than one keyword has been specified: ambiguity => stop the program

      write(6,'(1x,"Ambiguious input in DYNAMICS3: only ONE of (ISTATE, FCSTATE, PUMP) keywords must be specified.)")')
      call clean_exit

   endif

   !~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   !  Initial state is a pure adiabatic vibronic state
   !~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

   if (pure) then

      if (initial_state.lt.0) then
         ioption2 = index(options,' ISTATE=')
         write(6,'(/1x,"(Initial state is a pure adiabatic electron-proton vibronic state)")')
      endif

      initial_state = reada(options,ioption2+8)
      if (initial_state.eq.0) initial_state = 1

      if (mode_dyn.eq.'ADIAB') then

         if (initial_state.le.0) initial_state = 1
         write(6,'(1x,"At t=0: initial adiabatic state: ",i6)') initial_state

      elseif (mode_dyn.eq.'DIAB2') then

         if (iset_dyn.eq.1) then
            write(6,'(1x,"At t=0: initial vibronic state: ",i6," within the first (1a/1b) ET subset")') initial_state
         elseif (iset_dyn.eq.2) then
            write(6,'(1x,"At t=0: initial vibronic state: ",i6," within the second (2a/2b) ET subset")') initial_state
         endif

      elseif (mode_dyn.eq.'DIAB4') then

         if (iset_dyn.eq.1) then
            write(6,'(1x,"At t=0: initial vibronic state: ",i6," within the 1a electronic set")') initial_state
         elseif (iset_dyn.eq.2) then
            write(6,'(1x,"At t=0: initial vibronic state: ",i6," within the 1b electronic set")') initial_state
         elseif (iset_dyn.eq.3) then
            write(6,'(1x,"At t=0: initial vibronic state: ",i6," within the 2a electronic set")') initial_state
         elseif (iset_dyn.eq.4) then
            write(6,'(1x,"At t=0: initial vibronic state: ",i6," within the 2b electronic set")') initial_state
         endif

      endif

   endif

   !~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   !  Initial state is a product of the diabatic electronic state and
   !  proton vibrational wavepacket (vertical Franck-Condon excitation)
   !~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

   if (fcdia) then

      write(6,'(/1x,"Initial state is a product of the diabatic electronic state and")')
      write(6,'( 1x,"proton vibrational wavepacket (vertical Franck-Condon excitation)")')

      !-- read the initial diabatic electronic state (after FC exitation)

      ioption = index(options,' FCSTATE=')
      if (ioption.eq.0) then
         write(6,'(1x,"(From DYNAMICS3: You must specify the FCSTATE keyword for this type of the initial condition)")')
         call clean_exit
      endif
      initial_state = reada(options,ioption+9)
      write(6,'(/1x,"Photoexcited diabatic electronic state: ",a)') iset_char_diab4(initial_state)

      !-- read the position of the initial proton wave packet

      ioption = index(options,' WPPOS=')
      if (ioption.eq.0) then
         write(6,'(1x,"(From DYNAMICS3: You must specify the WPPOS keyword for this type of the initial condition)")')
         call clean_exit
      endif
      wp_position = reada(options,ioption+7)
      write(6,'(/1x,"Position of the initial proton wavepacket: ",f10.3," Angstroms")') wp_position

      !-- read the frequency of the initial proton wave packet

      ioption = index(options,' WPFREQ=')
      if (ioption.eq.0) then
         write(6,'(1x,"(From DYNAMICS3: You must specify the WPFREQ keyword for this type of the initial condition)")')
         call clean_exit
      endif
      wp_frequency = reada(options,ioption+8)
      write(6,'(/1x,"Frequency of the initial proton wavepacket: ",f12.3," cm^-1")') wp_frequency

      !-- read the quantum number of the initial proton wave packet

      ioption = index(options,' WPSTATE=')
      if (ioption.ne.0) then
         wp_state = reada(options,ioption+9)
         write(6,'(/1x,"Quantum number of the initial proton wavepacket: ",i2)') wp_state
      else
         wp_state = 1
         write(6,'(/1x,"Ground state initial proton wavepacket (default)")')
      endif

      !-- precalculate the proton vibrational wavefunctions for
      !   a harmonic potential specified by WPPOS and WPFEQ
      !   (stored in module quantum)

      call allocate_wp_wavefunction
      call precalculate_wp_wavefunction

      !--(DEBUG)-- Print the wavefunction of the initial proton wave packet
      !open(111,file="initial_wp.dat")
      !do k=1,npnts
      !   write(111,'(2f20.6)') rlist(k), wp_wavefunction(k)
      !enddo
      !close(111)

   endif

   !~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   !  Initial state is a result of a laser pump excitation from the
   !  ground vibronic state
   !~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

   if (pump) then

      ioption = index(options,' PUMP=')

      write(6,'(/1x,"Initial condition corresponds to the laser pump experiment:",/,&
      &         1x," the initial state for each trajectory is chosen according",/,&
      &         1x," to the magnitude of the transition dipole moment for the",/,&
      &         1x," transition from the ground vibronic state")')

      pump_e = reada(options,ioption+6)
      write(6,'(/1x,"Pump laser pulse energy: ",f13.6," eV")') pump_e

      !~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      !-- specify the vibronic state from which the system
      !   is photoexcited by the pump laser pulse
      !   (in the future release we will add the option of
      !   specifying an arbitrary prepared vibronic state)
      !~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

      ioption2 = index(options,' GROUND=')

      if (ioption2.ne.0) then
         iground = reada(options,ioption2+8)
         write(6,'(1x,"The system is photoexcited from the adiabatic vibronic state ",i3)') iground
      else
         iground = 1
         write(6,'(1x,"The system is photoexcited from the ground adiabatic vibronic state (default)")')
      endif

      !~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      ! Specify the laser pulse characteristics
      ! - width
      ! - lineshape
      !~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

      ioption2 = index(options,' PUMPWIDTH=')

      if (ioption2.ne.0) then
         pump_w = reada(options,ioption2+11)
         write(6,'(1x,"Pump laser linewidth (full width at half maximum) (eV): ",f13.6)') pump_w
      else
         write(6,'(1x,"(From DYNAMICS3: You must specify the PUMPWIDTH keyword for this type of the initial condition)")')
         call clean_exit
      endif

      ioption2 = index(options,' PUMPSHAPE=')

      if (ioption2.ne.0) then

         !-- extract the keyword for the PUMP line shape
         ispa = index(options(ioption2+11:),space)
         str = options(ioption2+11:ioption2+ispa+9)

         if (str.eq."RECTANGULAR") then
            pump_s = 0
         elseif (str.eq."LORENTZIAN") then
            pump_s = 1
         elseif (str.eq."GAUSSIAN") then
            pump_s = 2
         else
            write(6,'(/1x,"From DYNAMICS3: Unknown pump lineshape: ",a)') trim(str)
            call clean_exit
         endif

         write(6,'(1x,"Pump laser lineshape: ",a)') trim(str)

      else

         write(6,'(1x,"(From DYNAMICS3: You must specify the PUMPSHAPE keyword for this type of the initial condition)")')
         call clean_exit

      endif

      !-- set variables in the laser module
      call set_laser(pump_s,pump_e,pump_w)

      !~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      !  Vibronic spectrum
      !~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

      ioption = index(options," SPECTRUM=")

      if (ioption.eq.0) then

         open(11,file=job(1:ljob)//"/vibronic_spectrum.dat")
         write(6,'(/1x,"Vibronic spectrum is written to the external file ",a)') &
         &job(1:ljob)//"/vibronic_spectrum.dat"

      else

         ispa = index(options(ioption+10:),space)
         fname = options(ioption+10:ioption+ispa+8)
         lenf = ispa - 1
         call locase(fname,lenf)
         fname = job(1:ljob)//'/'//fname(1:lenf)
         lenf = lenf + ljob + 1

         open(11,file=fname(1:lenf))
         write(6,'(/1x,"Vibronic spectrum is written to the external file ",a)') fname(1:lenf)

      endif

      !-- first, calculate the absorption spectrum
      !   (including oscillator strengths)

      call calculate_absorption_prob(iground,kg0,z10,z20)

      !-- print to an external file (11)
      call print_vibronic_spectrum(11,iground)
      close(11)

      !-- print to the standard output as well
      call print_vibronic_spectrum(6,iground)

      !~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      !  Convoluted vibronic spectrum
      !  (Lorentzian and Gaussian convolutions are implemented)
      !~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

      ioption = index(options," CONVOLUTION=")

      if (ioption.ne.0) then

         !-- extract the keyword for the convoluting function
         ispa = index(options(ioption+13:),space)
         str = options(ioption+13:ioption+ispa+11)

         !-- extract the vibronic linewidth (eV)
         ioption2 = index(options," LINEWIDTH=")
         if (ioption2.ne.0) then
            vib_linewidth = reada(options,ioption2+11)
         else
            vib_linewidth = 0.05
         endif

         if (str.eq."LORENTZIAN") then

            write(6,'(/1x,"Vibronic spectrum with Lorentzian convolution will be written to the external file ",a)') &
            &job(1:ljob)//"/vibronic_spectrum_conv.dat"
            write(6,'(1x,"Vibronic linewidth: ",f13.6," eV")') vib_linewidth

            open(11,file=job(1:ljob)//"/vibronic_spectrum_lconv.dat")
            call print_vibronic_spectrum_conv(11,iground,1,vib_linewidth)

         elseif (str.eq."GAUSSIAN") then

            write(6,'(/1x,"Vibronic spectrum with Gaussian convolution will be written to the external file ",a)') &
            &job(1:ljob)//"/vibronic_spectrum_conv.dat"
            write(6,'(1x,"Vibronic linewidth: ",f13.6," eV")') vib_linewidth

            open(11,file=job(1:ljob)//"/vibronic_spectrum_gconv.dat")
            call print_vibronic_spectrum_conv(11,iground,2,vib_linewidth)

         else

            write(6,'(/1x,"(WARNING) Unknown convolution type: ",a)') trim(str)
            write(6,'( 1x,"Vibronic spectrum with Lorentzian (default) convolution will be written to the external file ",a)') &
            &job(1:ljob)//"/vibronic_spectrum_conv.dat"
            write(6,'(1x,"Vibronic linewidth: ",f13.6," eV")') vib_linewidth

            open(11,file=job(1:ljob)//"/vibronic_spectrum_lconv.dat")
            call print_vibronic_spectrum_conv(11,iground,1,vib_linewidth)

         endif

         close(11)

      endif

      !~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      !  Output the laser pulse shape to the external file
      !~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

      write(6,'(/1x,"Pump laser spectrum will be written to the external file ",a)') &
      & job(1:ljob)//"/pump_laser_spectrum.dat"

      open(11,file=job(1:ljob)//"/pump_laser_spectrum.dat")
      call print_laser_spectrum(11)
      close(11)

   endif

   !===DEBUG===
   !call print_propagators_3d

   !~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   ! Output files for trajectories
   !~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

   ioutput = index(options,' TRAJOUT=')

   if (ioutput.eq.0) then

      fname = job(1:ljob)//'/trajectory'
      lenf = ljob + 11

   else

      ispa = index(options(ioutput+9:),space)
      fname = options(ioutput+9:ioutput+ispa+7)
      lenf = ispa - 1
      call locase(fname,lenf)
      fname = job(1:ljob)//'/'//fname(1:lenf)
      lenf = lenf + ljob + 1

   endif

   !~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   ! Append "adiab" or "diab" to the trajectory file names
   !~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

   if (adiab) then
      fname = trim(fname)//"_adiab"
   elseif (diab2) then
      fname = trim(fname)//"_diab2_"//iset_char_diab2(iset_dyn)
   elseif (diab4) then
      fname = trim(fname)//"_diab4_"//iset_char_diab4(iset_dyn)
   endif

   write(6,'(/1x,"Trajectory data are written to the file(s) <",a,">"/)') trim(fname)//"_<xxxxxx>.dat"

   !======================================!
   !      MAIN LOOP OVER TRAJECTORIES     !
   !======================================!

   zeit_start = second()

   number_of_skipped_trajectories = 0
   number_of_failed_trajectories = 0
   itraj_start = 1
   ntraj_valid = ntraj

   !~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   ! Restart trajectories
   ! (restore all random seeds from the checkpoint file)
   !~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

   ioption = index(options," RESTART")

   if (ioption.ne.0) then

      if (options(ioption+8:ioption+8).eq."=") then
         ispa = index(options(ioption+9:),space)
         fname = options(ioption+9:ioption+ispa+7)
         call locase(fname,ispa-1)
      else
         fname = job(1:ljob)//".dchk"
      endif

      !-- open checkpoint file

      open(unit=1,file=trim(fname),action="read",form="unformatted",status="old")

      !-- read last trajectory number etc.
      read(1) itraj_start, number_of_skipped_trajectories, number_of_failed_trajectories
      itraj_start = itraj_start + 1
      write(6,'(/1x,"Restarting from trajectory: ",i6)') itraj_start

      !-- restore random seeds
      call restore_random_seeds(1)

      !-- close checkpoint file
      close(1)

   endif

   !~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   !-- initialize DUNI() random number generator
   !~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   call initialize_duni()

   !~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   !-- start (restart) loop over trajectories
   !~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

   loop_over_trajectories: do itraj=itraj_start,ntraj

      !-- initialize the suffix of the output file

      write(traj_suffix,'(i6.6)') itraj

      write(6,'(/1x,60("#"))')
      write(6,'( 1x,"Trajectory #",i10)') itraj
      write(6,'( 1x,60("#")/)')

      !-- pick the initial values of solvent coordinates
      !   from gaussian distribution centered at (z10,z20)

      sigma = sqrt(kb*temp/f0)
      sample = gaussdist_boxmuller()
      z1 = z10 + sigma*sample
      sample = gaussdist_boxmuller()
      z2 = z20 + sigma*sample

      !if (solvent_model.eq."ONODERA2") then
      !   !-- assign the initial values of auxiliary solvent coordinates
      !   y1 = -z1
      !   y2 = -z2
      !endif

      if (solvent_model.eq."ONODERA2") then
         !-- pick the initial values of auxiliary solvent coordinates
         !   from gaussian distribution centered at (-z10,-z20)
         sigma = sqrt(kb*temp/gamma)
         sample = gaussdist_boxmuller()
         y1 = -z10 + sigma*sample
         sample = gaussdist_boxmuller()
         y2 = -z20 + sigma*sample
      endif

      !--(DEBUG)--start
      !-- ignoring sampling
      !z1 = z10
      !z2 = z20
      !if (solvent_model.eq."ONODERA2") then
      !   y1 = -z10
      !   y2 = -z20
      !endif
      !--(DEBUG)--end

      !-- zero out the moments (A-FSSH)
      if (mdqt.and.afssh) then
         call reset_zmoments
         call reset_pzmoments
      endif

      !-- initialize initial velocities

      if (solvent_model.eq."DEBYE".or.solvent_model.eq."DEBYE2") then

         !-- overdamped dynamics
         vz1 = 0.d0
         vz2 = 0.d0

      elseif (solvent_model.eq."ONODERA") then

         !-- initial velocities from Maxwell distribution
         sigma1 = sqrt(kb*temp/effmass1)
         sigma2 = sqrt(kb*temp/effmass2)
         sample = gaussdist_boxmuller()
         vz1 = sigma1*sample
         sample = gaussdist_boxmuller()
         vz2 = sigma2*sample

      elseif (solvent_model.eq."ONODERA2") then

         !-- initial velocities from Maxwell distribution
         sigma1 = sqrt(kb*temp/effmass1)
         sigma2 = sqrt(kb*temp/effmass2)
         sample = gaussdist_boxmuller()
         vz1 = sigma1*sample
         sample = gaussdist_boxmuller()
         vz2 = sigma2*sample

      else

         !-- Other models are not implemented yet...
         write(6,'(1x,"(From DYNAMICS3: solvent model ",a10," is not implemented: abort calculation)")') solvent_model
         call clean_exit

      endif

      !-- Assign the initial occupied state

      if (pure) then

         !-- always the same initial state
         istate = initial_state

         if (istate.gt.nstates_dyn) then
            write(6,'(/1x,"From DYNAMICS3: index of the initial pure state specified (",i2,") ",/,&
            &          1x,"is greater than the number of states included in dynamics (",i2,").",/,&
            &          1x,"Check the ISTATE option!")') istate, nstates_dyn
            call clean_exit
         endif

         if (mdqt) then
            !-- set initial amplitudes (and/or density matrix) at t=0
            !   (always a pure state)
            call set_initial_amplitudes_pure(istate)
            call set_initial_density_pure(istate)
         endif

      elseif (pump) then

         !-- choose the initial state according to the magnitude
         !   of the transition dipole matrix element
         !   (choose randomly according to transition dipole
         !   moment magnitude)

         call calculate_absorption_prob(iground,kg0,z1,z2)
         istate = assign_initial_state(iground)

         if (istate.eq.0) then
            write(6,'(1x,"From DYNAMICS3: FAILURE to assign the initial vibronic state after laser excitation.")')
            write(6,'(1x,"Consider to include more states in NSTATES.")')
            call clean_exit
         endif

         if (mdqt) then

            !-- set initial amplitudes (and/or density matrix) at t=0

            if (purestate) then
               call set_initial_amplitudes_pure(istate)
               call set_initial_density_pure(istate)
            else
               call set_initial_amplitudes_laser
               call set_initial_density_laser
            endif

         endif

      elseif (fcdia) then

         !-- initial state is a product of the specified
         !   diabatic electronic state (1a, 1b, 2a, 2b)
         !   and harmonic proton vibrational wavepacket
         !   (any state of a harmonic oscillator)

         call calculate_fc_prob(initial_state,kg0,z1,z2)
         istate = assign_fc_state()

         if (istate.eq.0) then
            write(6,'(1x,"FAILURE to assign the initial vibronic state after Franck-Condon excitation.")')
            write(6,'(1x,"The trajectory ",i6," will be discarded.")') itraj
            number_of_skipped_trajectories = number_of_skipped_trajectories + 1
            cycle loop_over_trajectories
         endif

         if (mdqt) then

            !-- set initial amplitudes (and/or density matrix) at t=0

            if (purestate) then
               call set_initial_amplitudes_pure(istate)
               call set_initial_density_pure(istate)
            else
               call set_initial_amplitudes_fc
               call set_initial_density_fc
            endif

         endif

      else

         write(6,'(/1x,"From DYNAMICS3: For unknown reason (a serious bug?) no initial condition was chosen. Abort.")')
         call clean_exit

      endif

      !-- print out the initial amplitudes of the time-dependent wavefunction
      if (mdqt) call print_initial_amplitudes(6)

      !-- reset the counter of calls to feszz3
      call reset_feszz3_counter

      !-- calculate adiabatic states at t=0 (very first time for this trajectory)
      call calculate_vibronic_states(kg0,z1,z2)

      !-- in case of MDQT trajectory initialize the quantum
      !   amplitudes of the initial wavefunction

      if (mdqt) then

         !-- calculate vibronic couplings at t=0
         call calculate_vibronic_couplings

         if (collapse_region_coupling) then
            interaction_region = interaction_region_check()
            interaction_region_prev = interaction_region
         endif

         !-- calculate force matrices (A-FSSH specific)
         if (afssh) call calculate_force_matrices(z1,z2)

      endif

      !-- open the trajectory output file (channel 1)

      open(itraj_channel,file=trim(fname)//"_"//traj_suffix//".dat")

      !-- write the header of the trajectory file

      if (weights) then
         call get_evb_weights
         write(itraj_channel,'("#",168("="))')
      else
         write(itraj_channel,'("#",141("="))')
      endif
      write(itraj_channel,'("#   Data for the trajectory #",i6.6)') itraj
      if (weights) then
         write(itraj_channel,'("#",168("-"))')
         write(itraj_channel,'("#",t6,"t(ps)",t20,"z1",t32,"z2",t44,"vz1",t56,"vz2",t68,"zp",t80,"ze",t92,"vzp",t103,"vze",t115,"Ekin",t126,"Efe",t135,"occ.",t150,"EVB weights (1a,1b,2a,2b)",t202,"Ekin1",t214,"Ekin2")')
         write(itraj_channel,'("#",168("-"))')
      else
         write(itraj_channel,'("#",141("-"))')
         write(itraj_channel,'("#",t6,"t(ps)",t20,"z1",t32,"z2",t44,"vz1",t56,"vz2",t68,"zp",t80,"ze",t92,"vzp",t103,"vze",t115,"Ekin",t126,"Efe",t135,"occ.",t144,"Ekin1",t153,"Ekin2")')
         write(itraj_channel,'("#",141("-"))')
      endif

      write(6,'(/1x,"===> Trajectory ",i5," starts on the vibronic state ",i3)') itraj, istate
      write(6,'( 1x,"===> Initial solvent coordinates (z1,z2), (kcal/mol)^(1/2): ",2f13.6)') z1, z2

      write(6,*)
      write(6,'(141("-"))')
      write(6,'(t6,"t(ps)",t20,"z1",t32,"z2",t44,"vz1",t56,"vz2",t68,"zp",t80,"ze",t92,"vzp",t103,"vze",t115,"Ekin",t126,"Efe",t135,"occ.")')
      write(6,'(141("-"))')

      !write(6,'(137x,$)')


      !--(DEBUG)--start
      if (ndump777.ne.0) then
         open(777,file=job(1:ljob)//"/populations_"//traj_suffix//".dat")
         open(778,file=job(1:ljob)//"/coherences_"//traj_suffix//".dat")
      endif
      !--(DEBUG)--end


      !-- transform initial values at time t=0
      call z1z2_to_zpze(z1,z2,zp,ze)
      call v1v2_to_vpve(vz1,vz2,vzp,vze)

      !-- initial free energy (PMF)
      efes = get_free_energy(istate)

      !-- initial kinetic energy
      ekin1 = half*f0*tau0*taul*vz1*vz1
      ekin2 = half*f0*tau0*taul*vz2*vz2
      ekin = ekin1 + ekin2

      if (weights) then
          write(itraj_channel,'(f13.6,10f12.5,i5,4f10.3,2f12.5)') &
          & 0.d0, z1, z2, vz1, vz2, zp, ze, vzp, vze, ekin, efes, istate, (wght(k,istate),k=1,ielst_dyn), ekin1, ekin2
      else
          write(itraj_channel,'(f13.6,10f12.5,i5,2f12.5)') &
          & 0.d0, z1, z2, vz1, vz2, zp, ze, vzp, vze, ekin, efes, istate, ekin1, ekin2
      endif

      number_of_switches = 0
      number_of_rejected = 0

      traj_time_start = second()

      !===============================!
      !   MAIN LOOP OVER TIME STEPS   !
      !===============================!
      loop_over_time: do istep=1,nsteps

         switch = .false.

         zeit_prev = real(istep-1,kind=8)*tstep
         zeit = real(istep,kind=8)*tstep

         !-- MDQT: store couplings, vibronic energies, and velocities
         !         from the previous step (for iterpolation)

         if (mdqt) then
            vz1_prev = vz1
            vz2_prev = vz2
            ekin_prev = ekin
            call store_vibronic_couplings                                 !  coupz(:,:) -> coupz_prev(:,:)
            if (collapse_region_coupling) interaction_region_prev = interaction_region
            call store_vibronic_energies                                  !  fe(:)      -> fe_prev(:)
            if (interpolation.eq."QUADRATIC") call store_wavefunctions    !  z(:,:)     -> z_prev(:,:)
            if (afssh) call store_force_matrices                    !  fmatz(:,:) -> fmatz_prev(:,:)
         endif

         !-- Propagate solvent coordinates and velocities

         if (solvent_model.eq."DEBYE") then

            !-- overdamped Langevin equation (pure Debye model)
            call langevin_debye_2d(istate,kg0,z1,z2,vz1,vz2,tstep,temp,ekin1,ekin2,efes)
            ekin = ekin1 + ekin2

         elseif (solvent_model.eq."DEBYE2") then

            !-- overdamped Langevin equation with memory friction
            !   (Debye model with two relaxation periods)
            !call langevin_debye2_2d(istate,kg0,z1,z2,vz1,vz2,tstep,temp,ekin1,ekin2,efes)
            !ekin = ekin1 + ekin2
            write(*,'(/1x,"DYNAMICS3: Debye2 propagator is not coded yet...")')
            call clean_exit

         elseif (solvent_model.eq."ONODERA") then

            !-- ordinary Langevin equation (Onodera model)
            call langevin_onodera_2d(istate,kg0,z1,z2,vz1,vz2,tstep,temp,ekin1,ekin2,efes)
            ekin = ekin1 + ekin2

         elseif (solvent_model.eq."ONODERA2") then

            !-- ordinary Langevin equation with memory friction
            !   (Onodera model with two relaxation periods)
            call langevin_onodera2_2d(istate,kg0,z1,z2,y1,y2,vz1,vz2,tstep,temp,ekin1,ekin2,ekinhalf1,ekinhalf2,efes)
            ekin = ekin1 + ekin2
            !write(*,'(/1x,"DYNAMICS3: Onodera2 propagator is not coded yet...")')
            !call clean_exit

         endif

         !----------------!
         !-- MDQT stage --!
         !----------------!

         if (mdqt) then

            !-- calculate vibronic couplings at t+dt
            !---------------------------------------
            call calculate_vibronic_couplings

            if (collapse_region_coupling) then
               !-- are we still in the interaction region?
               interaction_region = interaction_region_check()
            endif

            !-- Calculate the nonadiabatic coupling terms (v*d_{kl})
            !   at t and t+dt
            !-------------------------------------------------------
            call calculate_v_dot_d(vz1,vz1_prev,vz2,vz2_prev)

            !-- Calculate the nonadiabatic coupling terms (v*d_{kl})
            !   at half timestep for quadratic interpolation scheme
            !-------------------------------------------------------
            if (interpolation.eq."QUADRATIC") then
               call calculate_v_dot_d_mid(tstep)
            endif

            if (afssh) then

               !-- calculate force matrices at t+dt (A-FSSH)
               !------------------------------------------------------
               call calculate_force_matrices(z1,z2)

               !-- calculate interpolation coefficients for the force matrices
               !------------------------------------------------------------------
               call interpolate_force_matrices(zeit_prev,zeit)

            endif

            !-- calculate interpolation coefficients for the kinetic energy
            !   for phase-corrected surface hopping scheme
            !------------------------------------------------------------------
            if (phase_corr) then
               call interpolate_kinenergy(interpolation,zeit_prev,zeit,ekin1+ekin2,ekin_prev,ekinhalf1+ekinhalf2)
            endif

            !-- calculate interpolation coefficients for the adiabatic energies
            !------------------------------------------------------------------
            call interpolate_energy(zeit_prev,zeit)

            !-- calculate interpolation coefficients
            !   for the nonadiabatic coupling terms v*d_{kl}
            !-----------------------------------------------
            call interpolate_vdotd(interpolation,zeit_prev,zeit)

            !-- calculate the population of the current state at time t_prev
            !---------------------------------------------------------------
            population_current = calculate_population(istate)

            call reset_switch_prob

            !--(DEBUG)--start
            !if (istep.eq.19419) call print_propagators_3d
            !--(DEBUG)--end

            !-- propagate the amplitudes (or density matrix)
            !   and switching probabilities from t_prev to t
            !------------------------------------------------------------------

            nqsteps_var = nqsteps
            qtstep_var = qtstep
            call save_amplitudes
            if (afssh) then
               call save_density_matrix
               call save_moments
            endif

            24 continue
            call reset_switch_prob

            do iqstep=1,nqsteps_var

               zeitq_prev = (iqstep-1)*qtstep_var + zeit_prev
               zeitq = iqstep*qtstep_var + zeit_prev

               if (afssh) then

                  !-- propagate moments and amplitudes forward in time according (AFSSH)
                  !---------------------------------------------------------------------
                  if (phase_corr) then
                     call propagate_moments_and_amplitudes_phcorr(istate,zeitq_prev,qtstep_var)
                  else
                     call propagate_moments_and_amplitudes(istate,zeitq_prev,qtstep_var)
                  endif

               else

                  !-- propagate amplitudes forward in time according to TDSE
                  !----------------------------------------------------------
                  if (phase_corr) then
                     call propagate_amplitudes_phcorr_rk4(istate,zeitq_prev,qtstep_var)
                  else
                     call propagate_amplitudes_rk4(zeitq_prev,qtstep_var)
                  endif

               endif

               call calculate_density_matrix

               !-- calculate transition probabilities from current state
               !--------------------------------------------------------
               call calculate_bprob_amp(istate,zeitq)

               !-- accumulate swithing probabilities (array operation)
               !------------------------------------------------------
               call accumulate_switch_prob(qtstep_var)

            enddo

            !-- check the norm of the time-dependent wavefunction
            !-----------------------------------------------------
            wf_norm = tdwf_norm()

            if (abs(wf_norm-1.d0).gt.1.d-4) then

               write(*,'(/1x,"-------------------------------------------------------------------------------")')
               write(*,'( 1x,"DYNAMICS3: Amplitudes are not normalized after timestep ",i6)') istep
               write(*,'( 1x,"           Norm of the time-dependent wavefunction:     ",g20.10)') wf_norm
               write(*,'(/1x,"-------------------------------------------------------------------------------")')

               if (nqsteps_var.lt.maxnqsteps) then

                  !-- reduce the TDSE timestep by ten times and repeat the quantum propagation

                  nqsteps_var = nqsteps_var*10
                  qtstep_var = qtstep_var/10.d0

                  write(*,'( 1x,"Number of quantum timesteps is increased ten times to ",i6)') nqsteps_var
                  write(*,'( 1x,"and the quantum propagation will be repeated with a 10 times smaller timestep.")')
                  write(*,'(/1x,"-------------------------------------------------------------------------------")')

                  call restore_amplitudes
                  if (afssh) then
                     call restore_density_matrix
                     call restore_moments
                  endif
                  goto 24

               else

                  !-- discard the failed trajectory

                  write(*,'( 1x,"--- The trajectory ",i6," will be discarded-------------------------------"/)') itraj

                  number_of_failed_trajectories = number_of_failed_trajectories + 1

                  if (weights) then
                     write(itraj_channel,'("#",168("-"))')
                  else
                     write(itraj_channel,'("#",141("-"))')
                  endif

                  write(itraj_channel,'("# Amplitudes are not normalized after timestep ",i6)') istep
                  write(itraj_channel,'("# Norm of the time-dependent wavefunction:     ",g20.10)') wf_norm
                  write(itraj_channel,'("# This trajectory has failed... Even after several tries with smaller TDSE timesteps.")')

                  if (weights) then
                     write(itraj_channel,'("#",168("-"))')
                  else
                     write(itraj_channel,'("#",141("-"))')
                  endif

                  close(itraj_channel)
                  call system("mv "//trim(fname)//"_"//traj_suffix//".dat"//" "//trim(fname)//"_"//traj_suffix//".dat_failed")
                  cycle loop_over_trajectories

               endif

            endif

            !-----------------------------------------------------------------
            !-- check the traces of the matrices of moments (A-FSSH algorithm)
            !   (should be zero?)
            !-----------------------------------------------------------------
            !if (afssh) then
            !   zmom1_norm = zmom1_trace()
            !   zmom2_norm = zmom2_trace()
            !   pzmom1_norm = pzmom1_trace()
            !   pzmom2_norm = pzmom2_trace()
            !   if (abs(zmom1_norm).gt.1.d-6) then
            !      write(*,'(/1x,"-------------------------------------------------------------------------------")')
            !      write(*,'( 1x,"DYNAMICS3(A-FSSH): Trace(zmom1) is not zero at timestep ",i6)') istep
            !      write(*,'( 1x,"                   The value is: ",g20.10)') zmom1_norm
            !      write(*,'(/1x,"-------------------------------------------------------------------------------")')
            !   endif
            !   if (abs(zmom2_norm).gt.1.d-6) then
            !      write(*,'(/1x,"-------------------------------------------------------------------------------")')
            !      write(*,'( 1x,"DYNAMICS3(A-FSSH): Trace(zmom2) is not zero at timestep ",i6)') istep
            !      write(*,'( 1x,"                   The value is: ",g20.10)') zmom2_norm
            !      write(*,'(/1x,"-------------------------------------------------------------------------------")')
            !   endif
            !   if (abs(pzmom1_norm).gt.1.d-6) then
            !      write(*,'(/1x,"-------------------------------------------------------------------------------")')
            !      write(*,'( 1x,"DYNAMICS3(A-FSSH): Trace(pzmom1) is not zero at timestep ",i6)') istep
            !      write(*,'( 1x,"                   The value is: ",g20.10)') pzmom1_norm
            !      write(*,'(/1x,"-------------------------------------------------------------------------------")')
            !   endif
            !   if (abs(pzmom2_norm).gt.1.d-6) then
            !      write(*,'(/1x,"-------------------------------------------------------------------------------")')
            !      write(*,'( 1x,"DYNAMICS3(A-FSSH): Trace(pzmom2) is not zero at timestep ",i6)') istep
            !      write(*,'( 1x,"                   The value is: ",g20.10)') pzmom2_norm
            !      write(*,'(/1x,"-------------------------------------------------------------------------------")')
            !   endif
            !endif
            !-----------------------------------------------------------------


            !--(DEBUG)--start
            !
            !-- print out the populations and coherences (channels 777 and 778)

            if (ndump777.ne.0.and.mod(istep,ndump777).eq.0) then
               if (afssh) then
                  call print_populations_den(777,zeit)
                  call print_coherences_den(778,zeit,istate)
               else
                  call print_populations_amp(777,zeit)
                  call print_coherences_amp(778,zeit,istate)
               endif
            endif
            !--(DEBUG)--end



            !-- Normalize swithing probabilities by the current state population
            !   and zero out the negative ones
            !-------------------------------------------------------------------
            call normalize_switch_prob(population_current)

            !-- decision time: should we make a hop?
            !-------------------------------------------
            new_state = switch_state(istate)
            switch = new_state.ne.istate

            if (switch) then

               !-- attempt adjusting velocities (and possibly moments for A-FSSH)

               if (afssh) then
                  if (.not.along_moments) then
                     call adjust_velocities_and_moments(istate,new_state,vz1,vz2,success)
                  else
                     call adjust_velocities_and_moments_0(istate,new_state,vz1,vz2,success)
                  endif
               else
                  call adjust_velocities(istate,new_state,vz1,vz2,success)
               endif

               if (success) then

                  write(itraj_channel,'("#--------------------------------------------------------------------")')
                  write(itraj_channel,'("#  t  = ",f13.6," ps ==> SWITCH ",i3,"  -->",i3)') zeit,istate,new_state
                  write(itraj_channel,'("#  d  = (",f20.6,",",f20.6,")")') &
                  & get_vibronic_coupling(istate,new_state)
                  write(itraj_channel,'("# |d| = ",f20.6)') &
                  & sqrt(dot_product(get_vibronic_coupling(istate,new_state),get_vibronic_coupling(istate,new_state)))
                  write(itraj_channel,'("#--------------------------------------------------------------------")')

                  istate = new_state
                  number_of_switches = number_of_switches + 1

                  !-- Instantaneous decoherence algorithms (IDS and IDA): collapse the wavefunction after a successful hop
                  if (ids.or.ida) then
                     call collapse_wavefunction(istate)
                     call calculate_density_matrix
                  endif

               else

                  write(itraj_channel,'("#--------------------------------------------------------------------")')
                  write(itraj_channel,'("#  t  = ",f13.6," ps ==> REJECTED SWITCH ",i3,"  -->",i3)') zeit,istate,new_state
                  write(itraj_channel,'("#  d  = (",f20.6,",",f20.6,")")') &
                  & get_vibronic_coupling(istate,new_state)
                  write(itraj_channel,'("# |d| = ",f20.6)') &
                  & sqrt(dot_product(get_vibronic_coupling(istate,new_state),get_vibronic_coupling(istate,new_state)))
                  write(itraj_channel,'("#--------------------------------------------------------------------")')

                  number_of_rejected = number_of_rejected + 1

                  !-- Instantaneous decoherence algorithm (IDA): collapse the wavefunction after a rejected hop
                  if (ida) then
                     call collapse_wavefunction(istate)
                     call calculate_density_matrix
                  endif

               endif

            endif


            !-- A-FSSH specific part: collapsing events and resetting the moments

            if (afssh) then
               call collapse_and_reset_afssh_erratum(istate,tstep,dzeta)
               call calculate_density_matrix
            endif

            !-- Collapse the wavefunction if leaving the interaction region: "poor man's" decoherence
            if (collapse_region_coupling) then
               if (interaction_region_prev.and.(.not.interaction_region)) then
                  call collapse_wavefunction(istate)
                  call calculate_density_matrix
                  write(*,'("*** Leaving interaction region: wavefunction collapsed to pure state ",i2)') istate
               endif
            endif

            !-- Energy-based decoherence correction: damp the amplitudes using an approximate Granucci's prescription (GEDC)
            if (gedc) then
               call damp_amplitudes_gedc(istate,tstep,ekin,1.d0,0.1d0*au2cal)
               call calculate_density_matrix
            endif


         endif  !mdqt

         !---------------------------!
         !-- end of the MDQT stage --!
         !---------------------------!


         !-- calculate EVB weights
         if (weights) call get_evb_weights

         !-- write the current data to the trajectory file

         call z1z2_to_zpze(z1,z2,zp,ze)
         call v1v2_to_vpve(vz1,vz2,vzp,vze)

         if (mod(istep,ndump).eq.0) then
            if (weights) then
               write(itraj_channel,'(f13.6,10f12.5,i5,4f15.9,2f12.5)') &
               & zeit, z1, z2, vz1, vz2, zp, ze, vzp, vze, ekin, efes, istate, (wght(k,istate),k=1,ielst_dyn), ekin1, ekin2
            else
               write(itraj_channel,'(f13.6,10f12.5,i5,2f12.5)') &
               & zeit, z1, z2, vz1, vz2, zp, ze, vzp, vze, ekin, efes, istate, ekin1, ekin2
            endif
         endif

         !if (ndump6.gt.0.and.mod(istep,ndump6).eq.0) &
         !& write(6,'(137("\b"),f13.6,10f12.5,i5,$)') zeit, z1, z2, vz1, vz2, zp, ze, vzp, vze, ekin, efes, istate

         if (ndump6.gt.0.and.mod(istep,ndump6).eq.0) &
         & write(6,'(f13.6,10f12.5,i5)') zeit, z1, z2, vz1, vz2, zp, ze, vzp, vze, ekin, efes, istate

      enddo loop_over_time

      traj_time_end = second()

      if (weights) then
         write(itraj_channel,'("#",168("-"))')
      else
         write(itraj_channel,'("#",141("-"))')
      endif
      write(itraj_channel,'("# Number of allowed  switches: ",i5)') number_of_switches
      write(itraj_channel,'("# Number of rejected switches: ",i5)') number_of_rejected
      if (weights) then
         write(itraj_channel,'("#",168("-"))')
      else
         write(itraj_channel,'("#",141("-"))')
      endif
      close(itraj_channel)

      !--(DEBUG)--start
      !-- close files with populations and coherences
      if (ndump777.ne.0) then
         close(777)
         close(778)
      endif
      !--(DEBUG)--end

      write(6,*)
      write(6,'(141("-"))')
      write(6,'("# Total number of allowed  switches: ",i5)') number_of_switches
      write(6,'("# Total number of rejected switches: ",i5)') number_of_rejected
      write(6,'("# CPU time elapsed (sec):            ",f12.3)') traj_time_end - traj_time_start
      write(6,'(141("-"))')
      write(6,*)

      !~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      !-- save restart data to the binary checkpoint file
      !~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

      open(unit=1,file=job(1:ljob)//".dchk",action="write",form="unformatted",status="replace")

      !-- write last trajectory number etc.
      write(1) itraj, number_of_skipped_trajectories, number_of_failed_trajectories

      !-- save random seeds
      call save_random_seeds(1)

      !-- close checkpoint file
      close(1)

      if (reset_random) call reset_random_seed

   enddo loop_over_trajectories

   ntraj_valid = ntraj - number_of_skipped_trajectories - number_of_failed_trajectories

   if (ntraj_valid.le.0) ntraj_valid = 1
   zeit_end = second()
   zeit_total = zeit_end - zeit_start
   write(6,*)
   write(6,'(1x,"================================================================================")')
   write(6,'(1x,"Done. Number of trajectories generated: ",i6)') ntraj_valid
   write(6,'(1x,"      Number of discarded trajectories: ",i6)') number_of_skipped_trajectories
   write(6,'(1x,"      Number of failed trajectories:    ",i6)') number_of_failed_trajectories
   write(6,'(1x,"================================================================================")')
   write(6,'(1x,"Done. Time elapsed         (sec): ",f20.3)') zeit_total
   write(6,'(1x,"      Time per trajectory  (sec): ",f20.3)') zeit_total/ntraj_valid
   write(6,'(1x,"      Time per timestep    (sec): ",f20.3)') zeit_total/(ntraj_valid*nsteps)
   write(6,'(1x,"      Productivity rate (ps/day): ",f20.3)') 3600.d0*24.d0*tstep*ntraj_valid*nsteps/zeit_total
   write(6,'(1x,"================================================================================")')
   write(6,*)

   !-- Deallocate arrays in propagators module

   call deallocate_all_arrays

contains

   subroutine clean_exit
      call deallocate_all_arrays
      stop
   end subroutine clean_exit

end subroutine dynamics3

