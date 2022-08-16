function addFrom( from, pg, qg )

    for l = 1:length(from)
          line = from[l];
          k = network_data["branch"][string(line)]["f_bus"]
          m = network_data["branch"][string(line)]["t_bus"]
          if k == 1 || m==1
              if k==1
                  kd = sparse([k],[1],[1],2n_bus-1,1)
                  md = sparse([m],[1],[1],2n_bus-1,1)
                  mq = sparse([m+n_bus-1],[1],[1],2n_bus-1,1)

                  pg[ idx2pos[2kd] ] += gl[line]/(tap[line]^2)
                  pg[ idx2pos[kd+md] ] += -gl[line]/tap[line]
                  pg[ idx2pos[kd+mq] ] += bl[line]/tap[line]

                  qg[ idx2pos[2kd] ] += -(bl[line]+bls[line])/(tap[line]^2)
                  qg[ idx2pos[kd+md] ] += bl[line]/tap[line]
                  qg[ idx2pos[kd+mq] ] += gl[line]/tap[line]
              else
                  kd = sparse([k],[1],[1],2n_bus-1,1)
                  kq = sparse([k+n_bus-1],[1],[1],2n_bus-1,1)
                  md = sparse([m],[1],[1],2n_bus-1,1)


                  pg[ idx2pos[2kd] ] += gl[line]/(tap[line]^2)
                  pg[ idx2pos[2kq] ] += gl[line]/(tap[line]^2)
                  pg[ idx2pos[kd+md] ] += -gl[line]/tap[line]
                  pg[ idx2pos[md+kq] ] += -bl[line]/tap[line]

                  qg[ idx2pos[2kd] ] += -(bl[line]+bls[line])/(tap[line]^2)
                  qg[ idx2pos[2kq] ] += -(bl[line]+bls[line])/(tap[line]^2)
                  qg[ idx2pos[kd+md] ] += bl[line]/tap[line]
                  qg[ idx2pos[md+kq] ] += -gl[line]/tap[line]
              end
          else
              kd = sparse([k],[1],[1],2n_bus-1,1)
              kq = sparse([k+n_bus-1],[1],[1],2n_bus-1,1)
              md = sparse([m],[1],[1],2n_bus-1,1)
              mq = sparse([m+n_bus-1],[1],[1],2n_bus-1,1)

              pg[ idx2pos[2kd] ] += gl[line]/(tap[line]^2)
              pg[ idx2pos[2kq] ] += gl[line]/(tap[line]^2)
              pg[ idx2pos[kd+md] ] += -gl[line]/tap[line]
              pg[ idx2pos[kq+mq] ] += -gl[line]/tap[line]
              pg[ idx2pos[kd+mq] ] += bl[line]/tap[line]
              pg[ idx2pos[md+kq] ] += -bl[line]/tap[line]

              qg[ idx2pos[2kd] ] += -(bl[line]+bls[line])/(tap[line]^2)
              qg[ idx2pos[2kq] ] += -(bl[line]+bls[line])/(tap[line]^2)
              qg[ idx2pos[kd+md] ] += bl[line]/tap[line]
              qg[ idx2pos[kq+mq] ] += bl[line]/tap[line]
              qg[ idx2pos[kd+mq] ] += gl[line]/tap[line]
              qg[ idx2pos[md+kq] ] += -gl[line]/tap[line]
          end
    end
    return pg, qg
end
