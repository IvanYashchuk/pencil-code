! $Id: read_vectorfiles.f90,v 1.3 2003-09-02 13:43:12 dobler Exp $

!***********************************************************************
      program read_vectorfiles
!
!  combine vector files from different processors into one
!
!   8-aug-03/axel: coded
!
      use Cparam
      use General
!
      implicit none
!
      integer, parameter :: nt=999999,nvecmax=999999
      integer :: iproc,ipx,ipy,ipz,it,ivec,l,m,n,mm,nn
      integer :: lun,lun2=9
      real :: t=0.,v1,v2,v3
!
      character (len=120) :: fullname=''
      character (len=120) :: datadir='data',path=''
      character (len=5) :: chproc=''
!
!  open vector files in all directories
!
      do iproc=0,ncpus-1
        lun=10+iproc
        call chn(iproc,chproc,'read_vectorfiles')
        call safe_character_assign(path,trim(datadir)//'/proc'//chproc)
        call safe_character_assign(fullname,trim(path)//'/bvec.dat')
        open(lun,file=fullname,form='unformatted')
      enddo
      open(lun2,file='data/bvec.dat',form='unformatted')
!
!  loop over all times
!
      do it=1,nt
!
        do iproc=0,ncpus-1
          lun=10+iproc
!
!  position on the processor grid
!  x is fastest direction, z slowest
!
          ipx = 0
          ipy = modulo(iproc, nprocy)
          ipz = iproc/(nprocy)
!
!  make sure the time stamp is repeated only once!
!  jump out of the vector-reading loop when next time stamp encountered
!
          do ivec=1,nvecmax
            read(lun,end=999) l,m,n,v1,v2,v3
            mm=m+ipy*ny
            nn=n+ipz*nz
            if ((l==0.and.iproc==0).or.l>0) write(lun2) l,mm,nn,v1,v2,v3
            if (l==0) goto 888
          enddo
          print*,'nvecmax is too small!'
888       t=v1
        enddo
        print*,'t=',t
      enddo
!
999   continue
      print*,'finished OK, close files, iproc=',iproc
      do iproc=0,ncpus-1
        lun=10+iproc
        print*,'written full set of slices at t=',t
        close(lun)
      enddo
      close(lun2)
!
      if(ip==0) print*,ipx  !(keep compiler quiet)
!
      end
!***********************************************************************
