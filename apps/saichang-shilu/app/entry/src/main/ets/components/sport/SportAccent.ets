export class SportAccent {
  static colorOf(sportType: string): string {
    if (sportType === 'running') {
      return '#0B6BCB'
    }
    if (sportType === 'basketball') {
      return '#FF6B35'
    }
    if (sportType === 'football') {
      return '#0F766E'
    }
    if (sportType === 'badminton') {
      return '#7C3AED'
    }
    if (sportType === 'swimming') {
      return '#0369A1'
    }
    if (sportType === 'fitness') {
      return '#BE123C'
    }
    return '#475569'
  }

  static softBg(sportType: string): string {
    if (sportType === 'running') {
      return '#D7E9F8'
    }
    if (sportType === 'basketball') {
      return '#FFE8DC'
    }
    if (sportType === 'football') {
      return '#CCFBF1'
    }
    if (sportType === 'badminton') {
      return '#EDE9FE'
    }
    if (sportType === 'swimming') {
      return '#E0F2FE'
    }
    if (sportType === 'fitness') {
      return '#FFE4E6'
    }
    return '#E8ECF1'
  }
}
