export class BrainNav {
  static readonly NONE: string = ''
  static readonly DRILL: string = 'drill'
  static readonly PLAY: string = 'play'
  static readonly ARTICLE: string = 'article'
  static readonly ACHIEVE: string = 'achieve'
  static readonly ASSESS: string = 'assess'
  static readonly SCORE: string = 'score'
  static readonly MESSAGES: string = 'messages'

  static open(route: string, entityId: string): void {
    AppStorage.setOrCreate('brainEntityId', entityId)
    AppStorage.setOrCreate('quizRoute', route)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static openPlay(drillId: string, gameType: string): void {
    AppStorage.setOrCreate('brainEntityId', drillId)
    AppStorage.setOrCreate('brainGameType', gameType)
    AppStorage.setOrCreate('quizRoute', BrainNav.PLAY)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static openScore(score: number, title: string): void {
    AppStorage.setOrCreate('brainLastScore', score)
    AppStorage.setOrCreate('brainScoreTitle', title)
    AppStorage.setOrCreate('quizRoute', BrainNav.SCORE)
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  static close(): void {
    AppStorage.setOrCreate('quizRoute', BrainNav.NONE)
    AppStorage.setOrCreate('tabBarHidden', false)
  }
}
