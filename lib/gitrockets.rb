require "gitrockets/version"
require 'sprockets'

module Gitrockets
  class GitDigest
    def initialize(fallback_digest)
      @fallback_digest = fallback_digest
#       (Grit::Repo.new(Rails.root).tree / 'app/assets').contents.first.id
      @root = Grit::Repo.new(Rails.root).tree
      @trees = {}
    end

    def hexdigest() nil; end

    def file(name)
#       puts "digesting #{name}..."
      path = name.sub("#{Rails.root.to_s}/", '')
      basename = File.basename path
      tree = tree(File.dirname path)
      return @fallback_digest.file(name) unless tree

      id = tree.contents.detect {|c| c.basename == basename }.try(:id)
      Gitrockets::Digest.new id
    end

    private
    def tree(dir)
      @trees[dir] || (@trees[dir] = @root / dir)
    end
  end

  class Digest
    def initialize(val)
      @val = val
    end

    def hexdigest
      @val
    end

    def to_s
      @val
    end
  end
end

module Sprockets
  class Base
    def git_digest
      @git_digest ||= ::Gitrockets::GitDigest.new digest
    end

    def file_digest(path)
      if (stat = self.stat(path))
        if stat.file? || stat.directory?
          git_digest.file(path.to_s)
        end
      end
    end
  end
end
